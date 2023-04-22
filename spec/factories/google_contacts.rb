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

FactoryBot.define do
  factory :google_contact do
    account { association(:google_account) }

    sequence(:google_id) { |n| "#{n}_google_id" }
  end
end
