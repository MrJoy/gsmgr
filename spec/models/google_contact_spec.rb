# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_contacts
#
#  id                      :bigint           not null, primary key
#  display_name            :string
#  display_name_last_first :string
#  family_name             :string
#  given_name              :string
#  middle_name             :string
#  primary_email           :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  google_account_id       :bigint           not null
#  google_id               :string           not null
#
# Indexes
#
#  index_google_contacts_on_google_account_id_and_google_id  (google_account_id, lower((google_id)::text) varchar_pattern_ops) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

require "rails_helper"

RSpec.describe(GoogleContact) do
  subject(:google_contact) { build(:google_contact) }

  context("when validating") do
    it { is_expected.to(validate_presence_of(:google_id)) }
    it { is_expected.to(validate_uniqueness_of(:google_id).scoped_to(:google_account_id).ignoring_case_sensitivity) } # rubocop:disable Layout/LineLength
  end
end
