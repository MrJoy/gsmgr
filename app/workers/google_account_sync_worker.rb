# frozen_string_literal: true

# Asynchronously synchronize everything associated with a Google account.
class GoogleAccountSyncWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default", retry: true

  def perform(account_id)
    account = GoogleAccount.find(account_id)

    account.transaction do
      account.lock!
      GoogleCalendarSync.call(account.id)
      GoogleContactSync.call(account.id)
      GoogleContactGroupSync.call(account.id)
      account.contact_groups.each do |group|
        GoogleContactGroupMembersSync.call(group.id)
      end
      GoogleDriveInfoSync.call(account.id)
      GoogleDriveFilesSync.call(account.id)
    end
  end
end
