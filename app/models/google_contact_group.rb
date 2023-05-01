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

# Represents a GSuite contact.
class GoogleContactGroup < ApplicationRecord
  belongs_to :account,
             class_name:  "GoogleAccount",
             foreign_key: :google_account_id,
             inverse_of:  :contact_groups

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :contacts,
                          class_name:              "GoogleContact",
                          association_foreign_key: "google_contact_id"
  # rubocop:enable Rails/HasAndBelongsToMany

  validates :google_id,
            presence:   true,
            uniqueness: { scope: :google_account_id, case_sensitive: false, on: :create }

  ALLOWED_GROUP_TYPES = %w[GROUP_TYPE_UNSPECIFIED USER_CONTACT_GROUP SYSTEM_CONTACT_GROUP].freeze

  validates :name,           presence: true
  validates :formatted_name, presence: true
  validates :group_type,     inclusion: { in: ALLOWED_GROUP_TYPES }
end
