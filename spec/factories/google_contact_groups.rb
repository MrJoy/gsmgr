# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_contact_groups
#
#  id                :bigint           not null, primary key
#  formatted_name    :string           not null
#  group_type        :string           not null
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  google_account_id :bigint           not null
#  google_id         :string           not null
#
# Indexes
#
#  index_gcg_on_google_account_id_and_google_id  (google_account_id, lower((google_id)::text) varchar_pattern_ops) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

FactoryBot.define do
  factory :google_contact_group do
    account { association(:google_account) }

    sequence(:name)           { |n| "Group #{n}" }
    sequence(:formatted_name) { |n| "Group #{n}, Formatted" }
    sequence(:google_id)      { |n| "#{n}_google_id" }

    group_type { "USER_CONTACT_GROUP" }
  end
end
