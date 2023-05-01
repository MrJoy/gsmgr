# frozen_string_literal: true

# Update the Google contact groups of an account.
#
class GoogleContactGroupMembersSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(group_id)
    @group_id = group_id
  end

  def sync_memberships!(account, group, client)
    logger.info("REFRESHING CONTACT GROUP MEMBERS FOR: #{account.email} (id=#{account.id}), " \
                "#{group.name} (id=#{group.id})")

    group.lock!

    member_ids = client.fetch_contact_group_members(group.google_id)
    members = account.contacts.where(google_id: member_ids)
    group.contacts = members
    group.save!
  end

  def actual_perform(group, client)
    sync_memberships!(group, client)
  end

  def call
    group   = GoogleContactGroup.find(@group_id)
    account = group.account

    return if group.blank? || account.blank?

    client = client(account)

    sync_memberships!(account, group, client)
  end
end
