# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_contact_group_allowances
#
#  id                      :bigint           not null, primary key
#  access_level            :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  google_contact_group_id :bigint           not null
#  google_file_id          :bigint           not null
#
# Indexes
#
#  idx_gcgas_on_group_and_file  (google_contact_group_id,google_file_id) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a GSuite contact.
class GoogleContactGroupAllowance < ApplicationRecord
  belongs_to :contact_group,
             class_name:  "GoogleContactGroup",
             foreign_key: :google_contact_group_id,
             inverse_of:  :allowances,
             dependent:   nil

  belongs_to :file,
             class_name:  "GoogleFile",
             foreign_key: :google_file_id,
             inverse_of:  :allowances,
             dependent:   nil

  ALLOWED_ACCESS_LEVELS = %w[reader writer owner].freeze

  validates :access_level, inclusion: { in: ALLOWED_ACCESS_LEVELS }

  validates :file, uniqueness: { scope: :contact_group }
end
