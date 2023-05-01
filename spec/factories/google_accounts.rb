# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_accounts
#
#  id                       :bigint           not null, primary key
#  contact_group_sync_token :string
#  contact_sync_token       :string
#  email                    :string           not null
#  scopes                   :string           default([]), is an Array
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  google_id                :string           not null
#
# Indexes
#
#  index_google_accounts_on_email  (lower((email)::text) varchar_pattern_ops)
#  unique_google_accounts_idx      (lower((google_id)::text) varchar_pattern_ops) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

FactoryBot.define do
  factory :google_account do
    sequence(:google_id, &:to_s)
    sequence(:email) { |n| "FOO#{n}@domain.com" }
  end
end
