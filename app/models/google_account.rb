# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_accounts
#
#  id                 :bigint           not null, primary key
#  contact_sync_token :string
#  email              :string           not null
#  scopes             :string           default([]), is an Array
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  google_id          :string           not null
#
# Indexes
#
#  index_google_accounts_on_email  (lower((email)::text) varchar_pattern_ops)
#  unique_google_accounts_idx      (lower((google_id)::text) varchar_pattern_ops) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a GSuite account (whether GMail proper, or Google Apps / GSuite / whatever they call it
# these days.)
#
class GoogleAccount < ApplicationRecord
  validates :email, presence: true
  validates :google_id, presence: true, uniqueness: { case_sensitive: false }

  has_many :calendar_instances,
           class_name: "GoogleCalendarInstance",
           dependent:  :destroy,
           inverse_of: :account
  has_many :calendars,
           class_name: "GoogleCalendar",
           through:    :calendar_instances,
           inverse_of: :account
  has_many :contacts,
           class_name: "GoogleContact",
           dependent:  :destroy,
           inverse_of: :account

  def self.required_scopes
    %w[
      openid
      https://www.googleapis.com/auth/userinfo.email
      https://www.googleapis.com/auth/userinfo.profile
      https://www.googleapis.com/auth/calendar
      https://www.googleapis.com/auth/calendar.acls
      https://www.googleapis.com/auth/calendar.calendarlist
      https://www.googleapis.com/auth/calendar.calendars
      https://www.googleapis.com/auth/docs
      https://www.googleapis.com/auth/drive
      https://www.googleapis.com/auth/drive.appdata
      https://www.googleapis.com/auth/drive.metadata
      https://www.googleapis.com/auth/contacts
    ]
  end
end