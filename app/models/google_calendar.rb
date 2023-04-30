# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_calendars
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  google_id  :string           not null
#
# Indexes
#
#  unique_google_calendars_idx  (lower((google_id)::text) varchar_pattern_ops) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a calendar in GSuite.  For our purposes, a calendar exists independent of an account,
# and there exists a many-to-many relationship between calendars and accounts.  This is to handle
# calendar delegation gracefully.
class GoogleCalendar < ApplicationRecord
  has_many :calendar_instances,
           class_name: "GoogleCalendarInstance",
           dependent:  :destroy,
           inverse_of: :calendar

  has_many :accounts,
           class_name: "GoogleAccount",
           through:    :calendar_instances

  # Let DB handle uniqueness constraint, or `create_or_find_by!` will explode.
  validates :google_id, presence: true
end
