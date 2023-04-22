# frozen_string_literal: true

require "rails_helper"

RSpec.describe(GoogleContactSync, type: :command) do
  describe("#perform") do
    before do
      allow(GSuite::Client).to(receive(:new).and_return(google_client))

      # Ensure these exist before the code under test executes:
      modified_contact
      removed_contact

      described_class.call(google_account.id)
    end

    let(:modified_id)    { "1_google_id" }
    let(:removed_id)     { "2_google_id" }
    let(:added_id)       { "3_google_id" }
    let(:empty_id)       { "4_google_id" }
    let(:resurrected_id) { "5_google_id" }

    let(:google_account) { create(:google_account) }
    let(:modified_contact) do
      create(:google_contact,
             account:       google_account,
             google_id:     modified_id,
             primary_email: "old-primary@gmail.com",
             emails:        [
               build(:google_contact_email, email: "other_email_1@gmail.com"),
               build(:google_contact_email, email: "temporary-email@gmail.com"),
             ])
    end
    let(:removed_contact) do
      create(:google_contact, google_id: removed_id, account: google_account)
    end

    let(:modified_contact_raw) do
      GSuite::Raw::Contact.new(
        id:            modified_id,
        primary_email: "MODIFIED-primary@gmail.com",
        all_emails:    [
          "modified-PRIMARY@gmail.com", # Vary case to ensure canon. works
          "other_email_1@gmail.com",
          "other_email_2@gmail.com",
        ]
      )
    end

    let(:added_contact_raw) do
      GSuite::Raw::Contact.new(
        id:            added_id,
        primary_email: "primary@gmail.com",
        all_emails:    [
          "primary@GMail.com", # Vary case to ensure canon. works
          "other_email_3@gmail.com",
          "other_email_4@gmail.com",
        ]
      )
    end

    let(:empty_contact_raw) do
      # N.B. No emails at all is totally a thing that can happen with a contact, and there's no
      # point in having such a contact in our system.
      GSuite::Raw::Contact.new(
        id:            empty_id,
        primary_email: nil,
        all_emails:    []
      )
    end

    let(:google_client) do
      instance_double(
        GSuite::Client,
        credentials:    Google::Auth::UserRefreshCredentials.new,
        fetch_contacts: [
          [
            added_contact_raw,
            modified_contact_raw,
            empty_contact_raw,
          ],
          "next_sync_token_123",
        ]
      ).as_null_object
    end

    it("asks GMail to fetch the GMail contacts for the user") do
      expect(google_client).to(have_received(:fetch_contacts))
    end

    it("creates contacts that were added remotely, and not already reflected in the system") do
      expect(GoogleContact.find_by(google_id: added_id)).to(be_present)
    end

    it("doesn't create contacts that were added remotely, and have no emails") do
      expect(GoogleContact.find_by(google_id: empty_id)).to(be_nil)
    end

    it("stores primary email when creating contacts") do
      contact = GoogleContact.find_by(google_id: added_id)
      expect(contact.primary_email&.downcase).to(eq(added_contact_raw.primary_email&.downcase))
    end

    it("computes primary email changes to modified contacts") do
      contact = GoogleContact.find_by(id: modified_contact.id)
      expect(contact.primary_email).to(eq(modified_contact_raw.primary_email&.downcase))
    end

    it("computes email changes to modified contacts") do
      contact = GoogleContact.find_by(id: modified_contact.id)
      contact_emails = contact.emails.map(&:email)
      sorted_emails = contact_emails.sort
      expected_emails =
        [
          "modified-primary@gmail.com",
          "other_email_1@gmail.com",
          "other_email_2@gmail.com",
        ]
      expected_emails.sort!

      expect(sorted_emails).to(eq(expected_emails))
    end
  end
end
