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
    account.files.includes(:account, :permissions).index_by(&:google_id)
  end

  def fetch_remote_files(client)
    return @files.index_by(&:id) if @files

    incomplete, remote_files = client.fetch_files

    logger.warn("INCOMPLETE FILE LIST FOR #{account.email}!") if incomplete

    remote_files.index_by(&:id)
  end

  def create_new_permission!(account, remote_perm)
    logger.info("NEW PERMISSION FOR #{account.email}: #{remote_perm.id} " \
                "(#{remote_perm.email_address})")

    GoogleFilePermission.create!(
      google_account_id:    account.id,
      google_id:            remote_perm.id,
      email_address:        remote_perm.email_address,
      deleted:              remote_perm.deleted,
      role:                 remote_perm.role,
      target_type:          remote_perm.type,
      pending_owner:        remote_perm.pending_owner,
      allow_file_discovery: remote_perm.allow_file_discovery
    )
  end

  def update_permission!(local_perm, remote_perm)
    local_perm.email_address        = remote_perm.email_address
    local_perm.deleted              = remote_perm.deleted
    local_perm.role                 = remote_perm.role
    local_perm.target_type          = remote_perm.type
    local_perm.pending_owner        = remote_perm.pending_owner
    local_perm.allow_file_discovery = remote_perm.allow_file_discovery

    local_perm.save!
  end

  def process_permission(account, google_id, local_perm, remote_perm)
    logger.info("PROCESSING PERMISSION FOR #{account.email}: #{google_id} " \
                "(#{(remote_perm || local_perm)&.email_address})")

    if !local_perm
      create_new_permission!(account, remote_perm)
    elsif !remote_perm
      logger.info("REMOVING REMOTELY-DELETED PERMISSION FOR #{account.email}: #{google_id} " \
                  "(#{local_perm.email_address})")
      local_perm.destroy!
    else
      update_permission!(local_perm, remote_perm)
    end
  end

  def sync_permissions(account, remote_files)
    local_permissions  = account.permissions.index_by(&:google_id)
    remote_permissions = remote_files.values.map(&:permissions).flatten.uniq.index_by(&:id) # rubocop:disable Performance/ChainArrayAllocation

    all_ids = (remote_permissions.keys + local_permissions.keys).uniq

    all_ids.reject! { |id| id == "anyoneWithLink" }

    all_ids.each do |google_id|
      remote_permission = remote_permissions[google_id]
      local_permission  = local_permissions[google_id]
      process_permission(account, google_id, local_permission, remote_permission)
    end
  end

  def create_new_file!(account, remote_file, local_permissions)
    logger.info("NEW FILE FOR #{account.email}: #{remote_file.id} (#{remote_file.name})")

    permissions = remote_file.permissions.filter_map { |perm| local_permissions[perm.id] }

    GoogleFile.create!(
      google_account_id: account.id,
      google_id:         remote_file.id,
      mime_type:         remote_file.mime_type,
      name:              remote_file.name,
      permissions:,
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
  end

  # rubocop:disable Metrics/AbcSize
  def update_file!(local_file, remote_file, local_permissions)
    permissions = remote_file.permissions.filter_map { |perm| local_permissions[perm.id] }

    local_file.mime_type     = remote_file.mime_type
    local_file.name          = remote_file.name
    local_file.permissions   = permissions
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
  end
  # rubocop:enable Metrics/AbcSize

  def process_file(account, google_id, local_file, remote_file, local_permissions)
    logger.info("PROCESSING FILE FOR #{account.email}: #{google_id} " \
                "(#{(remote_file || local_file)&.name})")

    if !local_file
      create_new_file!(account, remote_file, local_permissions)
    elsif !remote_file
      logger.info("REMOVING REMOTELY-DELETED FILE FOR #{account.email}: #{google_id} " \
                  "(#{local_file.name})")
      local_file.destroy!
    else
      update_file!(local_file, remote_file, local_permissions)
    end
  end

  def sync_files(account, local_files, remote_files, local_permissions)
    logger.info("REFRESHING FILES FOR: #{account.email} (id=#{account.id})")

    all_ids = (remote_files.keys + local_files.keys).uniq

    all_ids.each do |google_id|
      remote_file = remote_files[google_id]
      local_file  = local_files[google_id]
      process_file(account, google_id, local_file, remote_file, local_permissions)
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

    local_files  = fetch_local_files(account)
    remote_files = fetch_remote_files(client)

    sync_permissions(account, remote_files)

    local_permissions = account.permissions.index_by(&:google_id)

    sync_files(account, local_files, remote_files, local_permissions)
  end

  def inspect; "#<#{self.class.name} @account_id=#{@account_id}>"; end

  def to_s; inspect; end
end
# rubocop:enable Metrics/ClassLength
