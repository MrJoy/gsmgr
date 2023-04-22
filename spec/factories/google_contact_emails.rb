# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_contact_emails
#
#  id                :bigint           not null, primary key
#  email             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  google_contact_id :bigint           not null
#
# Indexes
#
#  idx_gce_on_google_contact_id_and_email  (google_contact_id, lower((email)::text) varchar_pattern_ops) UNIQUE
#  index_google_contact_emails_on_email    (lower((email)::text) varchar_pattern_ops)
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

FactoryBot.define do
  factory :google_contact_email do
    contact { association(:google_contact) }

    sequence(:email) { |n| "email-#{n}@gmail.com" }
  end
end
