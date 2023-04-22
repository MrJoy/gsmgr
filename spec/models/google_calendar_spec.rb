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

require "rails_helper"

RSpec.describe(GoogleCalendar) do
  context("when validating") do
    subject { build(:google_calendar) }

    it { is_expected.to(validate_presence_of(:google_id)) }
  end
end
