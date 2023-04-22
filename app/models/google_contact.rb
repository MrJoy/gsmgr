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

# Represents a GSuite contact.
class GoogleContact < ApplicationRecord
  belongs_to :account,
             class_name:  "GoogleAccount",
             foreign_key: :google_account_id,
             inverse_of:  :contacts

  validates :google_id,
            presence:   true,
            uniqueness: { scope: :google_account_id, case_sensitive: false, on: :create }

  has_many :emails, class_name: "GoogleContactEmail", dependent: :destroy
end
