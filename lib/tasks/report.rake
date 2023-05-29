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
end
