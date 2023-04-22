# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_accounts
#
#  id                 :bigint           not null, primary key
#  contact_sync_token :string
#  email              :string           not null
#  scopes             :string           default([]), is an Array
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  google_id          :string           not null
#
# Indexes
#
#  index_google_accounts_on_email  (lower((email)::text) varchar_pattern_ops)
#  unique_google_accounts_idx      (lower((google_id)::text) varchar_pattern_ops) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

require "rails_helper"

RSpec.describe(GoogleAccount) do
  context("when validating") do
    subject { build(:google_account) }

    it { is_expected.to(validate_presence_of(:email)) }
    it { is_expected.to(validate_presence_of(:google_id)) }
  end
end
