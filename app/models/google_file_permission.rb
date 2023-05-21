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
#  google_file_id       :string           not null
#  google_id            :string           not null
#
# Indexes
#
#  idx_google_file_permissions_on_account_file_and_id  (google_account_id,google_file_id,google_id) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a GSuite contact.
class GoogleFilePermission < ApplicationRecord
  belongs_to :account,
             class_name:  "GoogleAccount",
             foreign_key: :google_account_id,
             dependent:   nil,
             inverse_of:  :permissions

  has_one :file,
          class_name:  "GoogleFile",
          primary_key: :google_file_id,
          foreign_key: :id,
          dependent:   nil

  validates :google_id,
            presence:   true,
            uniqueness: { scope: %i[google_account_id google_file_id], on: :create }
end
