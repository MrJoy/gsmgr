# frozen_string_literal: true

# Update the Files of an account.
#
# rubocop:disable Metrics/ClassLength
class GoogleDriveFilesSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(account_id, files = nil)
    @account_id = account_id
    @files      = files
  end

  def fetch_local_files(account)
    account.files.includes(:account, permissions: [:account]).index_by(&:google_id)
  end

  def fetch_remote_files(client)
    return @files.index_by(&:id) if @files

    incomplete, remote_files = client.fetch_files

    logger.warn("INCOMPLETE FILE LIST FOR #{account.email}!") if incomplete

    remote_files.index_by(&:id)
  end

  def create_new_permission!(local_file, remote_permission)
    local_file.permissions.create!(
      google_account_id:    local_file.google_account_id,
      google_id:            remote_permission.id,
      email_address:        remote_permission.email_address,
      allow_file_discovery: remote_permission.allow_file_discovery,
      deleted:              remote_permission.deleted,
      pending_owner:        remote_permission.pending_owner,
      target_type:          remote_permission.type,
      role:                 remote_permission.role
    )
  end

  def create_new_file!(account, remote_file)
    logger.info("NEW FILE FOR #{account.email}: #{remote_file.id} (#{remote_file.name})")

    file =
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
      )

    remote_file.permissions.each do |perm|
      create_new_permission!(file, perm)
    end
  end

  def update_permission!(local_perm, remote_perm)
    local_perm.email_address        = remote_perm.email_address
    local_perm.allow_file_discovery = remote_perm.allow_file_discovery
    local_perm.deleted              = remote_perm.deleted
    local_perm.pending_owner        = remote_perm.pending_owner
    local_perm.target_type          = remote_perm.type
    local_perm.role                 = remote_perm.role

    local_perm.save!
  end

  def process_permission(local_file, local_perm, remote_perm)
    if local_perm && remote_perm
      update_permission!(local_perm, remote_perm)
    elsif local_perm
      local_perm.destroy!
    elsif remote_perm
      create_new_permission!(local_file, remote_perm)
    end
  end

  # rubocop:disable Metrics/AbcSize
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

    local_file.save!

    local_perms  = local_file.permissions.index_by(&:google_id)
    remote_perms = remote_file.permissions.index_by(&:id)

    all_ids = (remote_perms.keys + local_perms.keys).uniq
    all_ids.each do |id|
      process_permission(local_file, local_perms[id], remote_perms[id])
    end
  end
  # rubocop:enable Metrics/AbcSize

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

  def sync_files(account, local_files, remote_files)
    logger.info("REFRESHING FILES FOR: #{account.email} (id=#{account.id})")

    all_ids = (remote_files.keys + local_files.keys).uniq

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
    GoogleAccount.transaction do
      account, client = account_and_client(@account_id)

      next if account.blank?

      local_files  = fetch_local_files(account)
      remote_files = fetch_remote_files(client)

      sync_files(account, local_files, remote_files)
    end
  end

  def inspect; "#<#{self.class.name} @account_id=#{@account_id}>"; end

  def to_s; inspect; end
end
# rubocop:enable Metrics/ClassLength
