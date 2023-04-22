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

# Represents an accounts view of, and access to a calendar.
class GoogleCalendarInstance < ApplicationRecord
  MISMATCH_ERROR = "Attempting to update from mismatched raw object.  Cowardly refusing to proceed."

  belongs_to :account,
             class_name:  "GoogleAccount",
             foreign_key: "google_account_id",
             inverse_of:  :calendar_instances

  belongs_to :calendar,
             class_name:  "GoogleCalendar",
             foreign_key: "google_calendar_id",
             inverse_of:  :calendar_instances

  validates :primary,     inclusion: { in: [true, false] }
  validates :access_role, presence: true
  validates :summary,     presence: true

  def from_raw(raw, calendar_id)
    self.google_calendar_id = calendar_id
    self.primary            = !!raw.primary
    self.access_role        = raw.access_role
    self.summary            = raw.summary
  end

  def to_raw
    GSuite::Raw::Calendar.new(
      id:          calendar.google_id,
      primary:,
      access_role:,
      summary:
    )
  end
end
