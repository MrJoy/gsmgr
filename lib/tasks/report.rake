# frozen_string_literal: true

namespace :report do
  desc "Find deviations in top-level folder permissions."
  task folder_deviations: :environment do |_task, args|
    args       = args.to_a
    account_id = args[0]

    puts "Processing top-level permissions for account ##{account_id}."
    account = GoogleAccount.find(account_id)

    shared_folder_ids =
      GoogleContactGroupAllowance
      .includes(file: :account)
      .where(file: { account: })
      .distinct
      .pluck(:google_file_id)

    res =
      GoogleFile
      .where(id: shared_folder_ids)
      .map { |file| [file.name, file.access_level_changes] }

    deviations = res.sum { |rec| rec.last.length }
    puts
    puts
    puts "#{deviations} #{"deviation".pluralize(deviations)} from expected permissions."

    next unless deviations.positive?

    puts
    puts "Changes needed:"
    puts
    res.each do |(fname, changes)|
      next if changes.empty?

      puts "#{fname}:"
      changes.sort_by(&:first).each do |(email, delta)|
        puts "  #{email}: #{delta.first} => #{delta.last}"
      end
      puts
    end
  end

  desc "Find deviations in individual file permissions."
  task file_deviations: :environment do |_task, args|
    args       = args.to_a
    account_id = args[0]

    puts "Processing file-level permissions for account ##{account_id}."
    account = GoogleAccount.find(account_id)

    shared_contact_groups =
      GoogleContactGroupAllowance
      .includes(:contact_group, file: :account)
      .where(file: { account: })
      .distinct
      .pluck(:google_contact_group_id)

    known_people =
      GoogleContactGroup
      .where(id: shared_contact_groups)
      .includes(:contacts)
      .map(&:contacts)
    known_people.flatten!
    known_people.map!(&:emails)
    known_people.flatten!
    known_people.map!(&:email)
    known_people.uniq!

    parents = { parent: :parent }
    4.times do
      parents = { parent: parents }
    end

    misshared_files =
      GoogleFile
      .all
      .includes(:account, parent: parents)
      .where(account:)
      .reject { |file| file.access_level_changes.empty? }

    deviations = misshared_files.length

    results = misshared_files.map { |file| [file.name, file.id, file.access_level_changes] }

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

    people =
      overshared_files
      .flat_map(&:last)
      .map(&:first)
      .inject({}) do |hsh, email| # rubocop:disable Style/CollectionMethods,Style/EachWithObject
        hsh[email] ||= 0
        hsh[email] += 1
        hsh
      end
    people = people.keys.sort

    unknown_people = people - known_people
    if unknown_people.any?
      puts
      puts "Unknown people, to whom at least one file is shared:"
      unknown_people.each do |email|
        puts "  #{email}"
      end
    end

    overshare_recipients =
      overshared_files
      .flat_map(&:last)
      .map(&:first)
      .inject({}) do |hsh, email| # rubocop:disable Style/CollectionMethods,Style/EachWithObject
        hsh[email] ||= 0
        hsh[email] += 1
        hsh
      end
    overshare_recipients = overshare_recipients.to_a
    overshare_recipients.sort_by!(&:last)
    overshare_recipients.reverse!
    if overshare_recipients.any?
      puts
      puts "People who files are over-shared to, by # of files:"
      overshare_recipients.each do |(email, count)|
        puts "  #{email}: #{count}"
      end
    end

    undershare_recipients =
      undershared_files
      .flat_map(&:last)
      .map(&:first)
      .inject({}) do |hsh, email| # rubocop:disable Style/CollectionMethods,Style/EachWithObject
        hsh[email] ||= 0
        hsh[email] += 1
        hsh
      end
    undershare_recipients = undershare_recipients.to_a
    undershare_recipients.sort_by!(&:last)
    undershare_recipients.reverse!
    if undershare_recipients.any?
      puts
      puts "People who files are under-shared to, by # of files:"
      undershare_recipients.each do |(email, count)|
        puts "  #{email}: #{count}"
      end
    end
  end
end
