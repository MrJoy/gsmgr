# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_calendar_instances
#
#  id                 :bigint           not null, primary key
#  access_role        :string           not null
#  primary            :boolean          not null
#  summary            :string           default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  google_account_id  :bigint           not null
#  google_calendar_id :bigint           not null
#
# Indexes
#
#  idx_gcal_instances_on_google_account_id_and_google_calendar_id  (google_account_id,google_calendar_id) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

FactoryBot.define do
  factory :google_calendar_instance do
    account            { association(:google_account) }
    calendar           { association(:google_calendar) }
    sequence(:summary) { |n| "foo#{n}@domain.com" }
    primary            { false }
    access_role        { "reader" }

    trait :primary do
      primary     { true }
      access_role { "owner" }
    end

    trait :writer do
      primary     { false }
      access_role { "writer" }
    end

    trait :reader do
      primary     { false }
      access_role { "reader" }
    end
  end
end
