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

# Represents an email in a Google Contact.
class GoogleContactEmail < ApplicationRecord
  belongs_to :contact,
             class_name:  "GoogleContact",
             foreign_key: "google_contact_id",
             inverse_of:  :emails

  validates :email, presence: true
end
