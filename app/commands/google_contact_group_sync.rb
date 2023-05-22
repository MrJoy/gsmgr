# frozen_string_literal: true

# Update the Google contact groups of an account.
#
class GoogleContactGroupSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(account_id)
    @account_id = account_id
  end

  def create_new_group!(account, group)
    logger.info("NEW CONTACT GROUP FOR #{account.normalized_email}: #{group.id} (#{group.name})")

    GoogleContactGroup.create!(
      google_account_id: account.id,
      google_id:         group.id,
      name:              group.name,
      formatted_name:    group.formatted_name,
      group_type:        group.group_type
    )
  end

  def fetch_local_groups(account, google_ids)
    account.contact_groups.includes(:account).where(google_id: google_ids).index_by(&:google_id)
  end

  def fetch_remote_groups(acct, client)
    sync_token                     = acct.contact_group_sync_token
    remote_groups, next_sync_token = client
                                     .fetch_contact_groups(sync_token:)

    remote_groups = remote_groups.index_by(&:id)

    [remote_groups, next_sync_token]
  end

  def update_group!(local_group, group)
    local_group.name           = group.name
    local_group.formatted_name = group.formatted_name
    local_group.group_type     = group.group_type
    local_group.save!
  end

  def process_group(account, google_id, local_group, group)
    logger.info("PROCESSING CONTACT GROUP FOR #{account.normalized_email}: #{google_id} " \
                "(#{group.name})")

    should_be_destroyed = group.deleted?

    if !local_group && !should_be_destroyed
      create_new_group!(account, group)
      return
    end

    return unless local_group

    if should_be_destroyed
      local_group.destroy!
      return
    end

    update_group!(local_group, group)
  end

  def actual_perform(account, client)
    logger.info("REFRESHING CONTACT GROUPS FOR: #{account.normalized_email} (id=#{account.id})")

    remote_groups, next_sync_token = fetch_remote_groups(account, client)
    local_groups = fetch_local_groups(account, remote_groups.keys)

    remote_groups.each do |google_id, group|
      local_group = local_groups[google_id]
      process_group(account, google_id, local_group, group)
    end

    account.contact_group_sync_token = next_sync_token
    account.save!
  rescue Google::Apis::ClientError => e
    if e.message.start_with?("FAILED_PRECONDITION: Sync token is expired.")
      handle_sync_token_expired!(account)
    end
    raise
  end

  def handle_sync_token_expired!(account)
    account.contact_group_sync_token = nil
    account.save!
  end

  def call
    account, client = account_and_client(@account_id)

    return if account.blank?

    actual_perform(account, client)
  end
end
