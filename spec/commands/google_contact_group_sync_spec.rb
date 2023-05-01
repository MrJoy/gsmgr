# frozen_string_literal: true

require "rails_helper"

RSpec.describe(GoogleContactGroupSync, type: :command) do
  describe("#perform") do
    before do
      allow(GSuite::Client).to(receive(:new).and_return(google_client))

      # Ensure these exist before the code under test executes:
      modified_group
      removed_group

      described_class.call(google_account.id)
    end

    let(:modified_id)    { "1_google_id" }
    let(:removed_id)     { "2_google_id" }
    let(:added_id)       { "3_google_id" }

    let(:google_account) { create(:google_account) }
    let(:modified_group) do
      create(:google_contact_group,
             account:        google_account,
             google_id:      modified_id,
             name:           "old-name",
             formatted_name: "old-formatted-name",
             group_type:     "GROUP_TYPE_UNSPECIFIED")
    end
    let(:removed_group) do
      create(:google_contact_group, google_id: removed_id, account: google_account)
    end

    let(:added_group_raw) do
      GSuite::Raw::ContactGroup.new(
        id:             added_id,
        name:           "added-name",
        formatted_name: "added-formatted-name",
        group_type:     "USER_CONTACT_GROUP",
        deleted:        false
      )
    end

    let(:modified_name)           { "NEW-name" }
    let(:modified_formatted_name) { "NEW-formatted-name" }
    let(:modified_group_type)     { "USER_CONTACT_GROUP" }

    let(:modified_group_raw) do
      GSuite::Raw::ContactGroup.new(
        id:             modified_id,
        name:           modified_name,
        formatted_name: modified_formatted_name,
        group_type:     modified_group_type,
        deleted:        false
      )
    end

    let(:removed_group_raw) do
      GSuite::Raw::ContactGroup.new(
        id:             removed_id,
        name:           "removed-name",
        formatted_name: "removed-formatted-name",
        group_type:     "USER_CONTACT_GROUP",
        deleted:        true
      )
    end

    let(:google_client) do
      instance_double(
        GSuite::Client,
        credentials:          Google::Auth::UserRefreshCredentials.new,
        fetch_contact_groups: [
          [
            added_group_raw,
            modified_group_raw,
            removed_group_raw,
          ],
          "next_sync_token_123",
        ]
      ).as_null_object
    end

    it("asks GMail to fetch the GMail contact groups for the user") do
      expect(google_client).to(have_received(:fetch_contact_groups))
    end

    it("creates groups that were added remotely, and not already reflected in the system") do
      expect(GoogleContactGroup.find_by(google_id: added_id)).to(be_present)
    end

    it("deletes groups that were deleted remotely") do
      expect(GoogleContactGroup.find_by(google_id: removed_id)).to(be_nil)
    end

    it("stores name when creating groups") do
      group = GoogleContactGroup.find_by(google_id: added_id)
      expect(group&.name).to(eq(added_group_raw.name))
    end

    it("stores formatted name when creating groups") do
      group = GoogleContactGroup.find_by(google_id: added_id)
      expect(group&.formatted_name).to(eq(added_group_raw.formatted_name))
    end

    it("stores group type when creating groups") do
      group = GoogleContactGroup.find_by(google_id: added_id)
      expect(group&.group_type).to(eq(added_group_raw.group_type))
    end

    it("stores name when updating groups") do
      group = GoogleContactGroup.find_by(google_id: modified_id)
      expect(group&.name).to(eq(modified_name))
    end

    it("stores formatted name when updating groups") do
      group = GoogleContactGroup.find_by(google_id: modified_id)
      expect(group&.formatted_name).to(eq(modified_formatted_name))
    end

    it("stores group type when updating groups") do
      group = GoogleContactGroup.find_by(google_id: modified_id)
      expect(group&.group_type).to(eq(modified_group_type))
    end
  end
end
