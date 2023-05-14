# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_file_permissions
#
#  id                   :bigint           not null, primary key
#  allow_file_discovery :boolean
#  deleted              :boolean
#  email_address        :string
#  pending_owner        :boolean
#  role                 :string           not null
#  target_type          :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  google_account_id    :bigint           not null
#  google_id            :string           not null
#
# Indexes
#
#  idx_google_file_permissions_on_google_account_id_and_google_id  (google_account_id,google_id) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a GSuite contact.
class GoogleFilePermission < ApplicationRecord
  belongs_to :account,
             class_name:  "GoogleAccount",
             foreign_key: :google_account_id,
             dependent:   nil,
             inverse_of:  :permissions

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :files,
                          class_name:              "GoogleFile",
                          association_foreign_key: "google_file_id"
  # rubocop:enable Rails/HasAndBelongsToMany

  validates :google_id,
            presence:   true,
            uniqueness: { scope: :google_account_id, case_sensitive: false, on: :create }
end
