# frozen_string_literal: true

namespace :repair do
  desc "Repair deviations in individual file permissions."
  task file_deviations: :environment do |_task, args|
    args       = args.to_a
    account_id = args[0]
    limit      = args[1]&.to_i || 0

    puts "Processing file-level permissions for account ##{account_id}."
    account = GoogleAccount.find(account_id)
    client = GSuite::Client.new(account.id, scopes: GoogleAccount.required_scopes)

    parents = { parent: :parent }
    4.times do
      parents = { parent: parents }
    end

    misshared_files = # TODO: Hoist this and DRY up with report.rake!
      GoogleFile
      .all
      .includes(:account, parent: parents)
      .where(account:)
    misshared_files = misshared_files.limit(limit) if limit.positive?
    misshared_files = misshared_files.reject { |file| file.access_level_changes.empty? }

    deviations = misshared_files.length

    results = misshared_files.map { |file| [file.name, file.id, file.access_level_changes] }

    file_map = misshared_files.index_by(&:id)

    overshared_files =
      results
      .filter_map do |(fname, id, changes)|
        res = [
          fname,
          id,
          changes.select do |(_email, (from, to))|
            GoogleFile::ACCESS_LEVELS[from] > GoogleFile::ACCESS_LEVELS[to]
          end,
        ]
        res unless res.last.empty?
      end
    over_devs = overshared_files.length

    undershared_files =
      results
      .filter_map do |(fname, id, changes)|
        res = [
          fname,
          id,
          changes.select do |(_email, (from, to))|
            GoogleFile::ACCESS_LEVELS[from] < GoogleFile::ACCESS_LEVELS[to]
          end,
        ]
        res unless res.last.empty?
      end
    under_devs = undershared_files.length

    puts
    puts
    puts "#{deviations} #{"file".pluralize(deviations)} with deviations from expected permissions."
    puts "#{over_devs} #{"file".pluralize(over_devs)} over-shared."
    puts "#{under_devs} #{"file".pluralize(under_devs)} under-shared."

    undershared_files.each do |(fname, id, changes)|
      file = file_map[id]
      perms = file.permissions.index_by { |pp| GSuite::Client.normalize_email(pp.email_address) }

      puts
      puts "File: #{fname} (#{id})"
      changes.each do |(email_address, (from, to))|
        puts "  #{email_address}: #{from || "(no access)"} -> #{to}"
        if from
          # Need to update a permission...
          perm = perms[email_address]
          puts "    Update required for permission ##{perm&.id}"
        else
          # Need to create a permission...
          permission_id = client.create_permission(file.google_id, email_address, to)
          puts "    Created permission: #{permission_id}"
        end
      rescue Google::Apis::ClientError => e
        if e.message.include?("notFound: invalidSharingRequest")
          puts "    Can't create permission, need to allow notifying!"
        else
          puts "    Can't create permission: #{e.message}"
        end
      end
    end

    overshared_files.each do |(fname, id, changes)|
      file = file_map[id]
      perms = file.permissions.index_by { |pp| GSuite::Client.normalize_email(pp.email_address) }

      puts
      puts "File: #{fname} (#{id})"
      changes.each do |(email_address, (from, to))|
        puts "  #{email_address}: #{from || "(no access)"} -> #{to}"
        if from && to
          # Need to update a permission...
          perm = perms[email_address]
          puts "    Update required for permission ##{perm&.id}"
        elsif from
          # Need to delete a permission...
          perm = perms[email_address]
          puts "    Permission ##{perm&.id} needs to be deleted."
          client.delete_permission(file.google_id, perm.google_id) if perm
        else
          puts "    WAT!"
        end
      rescue Google::Apis::ClientError => e
        if e.message.include?("notFound: invalidSharingRequest")
          puts "    Can't create permission, need to allow notifying!"
        else
          puts "    Can't create permission: #{e.message}"
        end
      end
    end
  end
end
