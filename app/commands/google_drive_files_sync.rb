# frozen_string_literal: true

# Update the Files of an account.
#
class GoogleDriveFilesSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(account_id)
    @account_id = account_id
  end

  def create_new_file!(account, remote_file)
    logger.info("NEW FILE FOR #{account.email}: #{remote_file.id} (#{remote_file.name})")

    GoogleFile.create!(
      google_account_id: account.id,
      google_id:         remote_file.id,
      mime_type:         remote_file.mime_type,
      name:              remote_file.name,
      owner:             remote_file.owner,
      capabilities:      remote_file.capabilities,
      quota_size:        remote_file.quota_size,
      shared:            remote_file.shared,
      spaces:            remote_file.spaces,
      starred:           remote_file.starred,
      trashed:           remote_file.trashed,
      shortcut:          remote_file.shortcut,
      web_view_link:     remote_file.web_view_link
      # TODO: Permissions.
    )
  end

  def fetch_local_files(account)
    account.files.includes(:account).index_by(&:google_id)
  end

  def fetch_remote_files(client)
    incomplete, remote_files = client.fetch_files

    logger.warn("INCOMPLETE FILE LIST FOR #{account.email}!") if incomplete

    remote_files.index_by(&:id)
  end

  def update_file!(local_file, remote_file)
    local_file.mime_type     = remote_file.mime_type
    local_file.name          = remote_file.name
    local_file.owner         = remote_file.owner
    local_file.capabilities  = remote_file.capabilities # TODO: Only update if changed!
    local_file.quota_size    = remote_file.quota_size
    local_file.shared        = remote_file.shared
    local_file.spaces        = remote_file.spaces
    local_file.starred       = remote_file.starred
    local_file.trashed       = remote_file.trashed
    local_file.shortcut      = remote_file.shortcut # TODO: Only update if changed!
    local_file.web_view_link = remote_file.web_view_link
    # TODO: Permissions...

    local_file.save!
  end

  def process_file(account, google_id, local_file, remote_file)
    logger.info("PROCESSING FILE FOR #{account.email}: #{google_id} " \
                "(#{(remote_file || local_file)&.name})")

    if !local_file
      create_new_file!(account, remote_file)
    elsif !remote_file
      logger.info("REMOVING REMOTELY-DELETED FILE FOR #{account.email}: #{google_id} " \
                  "(#{local_file.name})")
      local_file.destroy!
    else
      update_file!(local_file, remote_file)
    end
  end

  def actual_perform(account, client)
    logger.info("REFRESHING FILES FOR: #{account.email} (id=#{account.id})")

    remote_files = fetch_remote_files(client)
    local_files  = fetch_local_files(account)
    all_ids      = (remote_files.keys + local_files.keys).uniq

    all_ids.each do |google_id|
      remote_file = remote_files[google_id]
      local_file  = local_files[google_id]
      process_file(account, google_id, local_file, remote_file)
    end

    # TODO: Build a dependency tree, and update files top-down instead of taking two passes.
    account.files.each do |local_file|
      google_id = local_file.google_id

      logger.info("UPDATING PARENT FOR #{account.email}: #{google_id} (#{local_file.name})")

      remote_file  = remote_files[local_file.google_id]
      local_parent = local_files[remote_file.parent_id]

      local_file.parent = local_parent
      local_file.save!
    end
  end

  def call
    account, client = account_and_client(@account_id)

    return if account.blank?

    actual_perform(account, client)
  end
end
