# frozen_string_literal: true

# Update the Google contacts of an account.
#
# rubocop:disable Metrics/ClassLength
class GoogleContactSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(account_id)
    @account_id = account_id
  end

  def add_emails(contact, all_emails)
    all_emails.each do |raw_email|
      contact.emails.create!(raw_email:, email: GSuite::Client.normalize_email(raw_email))
    end
  end

  def update_emails!(local_contact, remote_contact)
    remote_emails = remote_contact.all_emails.map(&:downcase)

    local_emails = local_contact.emails.map(&:email) # TODO: Fix N+1!!
    local_emails.map!(&:downcase)

    added_emails, removed_emails = compute_email_sets(local_emails, remote_emails)

    local_contact.emails.where(email: removed_emails).destroy_all

    email_data =
      added_emails
      .map { |raw_email| { raw_email:, email: GSuite::Client.normalize_email(raw_email) } }
    local_contact.emails.create!(email_data)
  end

  def compute_email_sets(local_emails, remote_emails)
    unmap = {}
    local_emails.each do |email|
      unmap[GSuite::Client.normalize_email(email)] = email
    end
    remote_emails.each do |email|
      unmap[GSuite::Client.normalize_email(email)] = email
    end
    remote_cleansed = remote_emails.map { |email| GSuite::Client.normalize_email(email) }
    local_cleansed  = local_emails.map { |email| GSuite::Client.normalize_email(email) }

    added_emails    = remote_cleansed - local_cleansed
    removed_emails  = local_cleansed - remote_cleansed

    added_emails.uniq!
    added_emails.compact!

    removed_emails.uniq!
    removed_emails.compact!

    [added_emails.map { |email| unmap[email] }, removed_emails]
  end

  def create_new_contact!(account, contact)
    logger.info("NEW CONTACT FOR #{account.normalized_email}: #{contact.id} " \
                "(#{contact.primary_email})")

    new_contact = GoogleContact.create!(
      google_account_id:       account.id,
      google_id:               contact.id,
      primary_email:           contact.primary_email,
      display_name:            contact.display_name,
      display_name_last_first: contact.display_name_last_first,
      family_name:             contact.family_name,
      middle_name:             contact.middle_name,
      given_name:              contact.given_name
    )

    add_emails(new_contact, contact.all_emails)
  end

  def fetch_local_contacts(account, google_ids)
    account.contacts.includes(:account, :emails).where(google_id: google_ids).index_by(&:google_id)
  end

  def fetch_remote_contacts(acct, client)
    remote_contacts, next_sync_token = client
                                       .fetch_contacts(request_sync_token: true,
                                                       sync_token:         acct.contact_sync_token)

    remote_contacts = remote_contacts.index_by(&:id)
    remote_contacts.each do |_, contact|
      contact.all_emails =
        contact
        .all_emails
        &.compact
        &.uniq
    end
    [remote_contacts, next_sync_token]
  end

  def update_contact!(local_contact, contact)
    local_contact.primary_email           = contact.primary_email
    local_contact.display_name            = contact.display_name
    local_contact.display_name_last_first = contact.display_name_last_first
    local_contact.family_name             = contact.family_name
    local_contact.middle_name             = contact.middle_name
    local_contact.given_name              = contact.given_name
    local_contact.save!

    update_emails!(local_contact, contact)
  end

  def process_contact(account, google_id, local_contact, contact)
    logger.info("PROCESSING CONTACT FOR #{account.normalized_email}: #{google_id} " \
                "(#{contact.primary_email})")

    should_be_destroyed = !contact.primary_email && contact.all_emails.empty?

    if !local_contact && !should_be_destroyed
      create_new_contact!(account, contact)
      return
    end

    return unless local_contact

    if should_be_destroyed
      local_contact.destroy!
      return
    end

    update_contact!(local_contact, contact)
  end

  def actual_perform(account, client)
    logger.info("REFRESHING CONTACTS FOR: #{account.normalized_email} (id=#{account.id})")

    remote_contacts, next_sync_token = fetch_remote_contacts(account, client)
    local_contacts = fetch_local_contacts(account, remote_contacts.keys)

    logger.info("FOUND #{remote_contacts.length} CONTACTS IN GOOGLE, " \
                "AND #{local_contacts.length} LOCALLY")
    remote_contacts.each do |google_id, contact|
      local_contact = local_contacts[google_id]
      process_contact(account, google_id, local_contact, contact)
    end

    account.contact_sync_token = next_sync_token
    account.save!
  rescue Google::Apis::ClientError => e
    if e.message.start_with?("FAILED_PRECONDITION: Sync token is expired.")
      handle_sync_token_expired!(account)
      retry
    end
    raise
  end

  def handle_sync_token_expired!(account)
    account.contact_sync_token = nil
    account.save!
  end

  def call
    account, client = account_and_client(@account_id)

    return if account.blank?

    actual_perform(account, client)
  end
end
# rubocop:enable Metrics/ClassLength
