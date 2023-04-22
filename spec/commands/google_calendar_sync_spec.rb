# frozen_string_literal: true

require "rails_helper"

RSpec.describe(GoogleCalendarSync, type: :command) do
  describe("#perform") do
    before do
      allow(GSuite::Client).to(receive(:new).and_return(google_client))
      allow(GoogleAccount).to(receive(:find).and_return(google_account))

      # The user begins in a state where the system knows about:
      # * GoogleCalendars:
      #   * modified_calendar -- a calendar for which we have an out of date view of its attributes
      #   * removed_calendar -- a calendar that we don't yet know the user has lost access to
      #   * readded_calendar -- a calendar the user once had access to, lost access to, and which
      #     we don't yet know s/he has regained access to
      # * GoogleCalendarInstances corresponding to:
      #   * modified_id
      #   * removed_id
      #
      # When we are done, we expect to have a new GoogleCalendar (corresponding to added_id), and
      # GoogleCalendarInstances that correspond to:
      # * modified_id
      # * added_id
      # * readded_id
      #
      # Additionally, all GoogleCalendarInstances should have up-to-date details or be destroyed (as
      # appropriate).
      create(:google_calendar_instance, calendar: modified_calendar, account: google_account)
      create(:google_calendar_instance,
             calendar: removed_calendar,
             account:  google_account)

      described_class.call(google_account.id)
    end

    let(:modified_id) { "modified@test.com" }
    let(:removed_id)  { "removed@test.com" }
    let(:added_id)    { "added@test.com" }
    let(:readded_id)  { "readded@test.com" }

    let(:modified_calendar) { create(:google_calendar, google_id: modified_id) }
    let(:removed_calendar)  { create(:google_calendar, google_id: removed_id) }
    let(:readded_calendar)  { create(:google_calendar, google_id: readded_id) }
    let(:google_account)    { create(:google_account) }

    let(:modified_calendar_raw) do
      GSuite::Raw::Calendar.new(
        id:          modified_id,
        summary:     modified_id,
        primary:     true,
        access_role: "something"
      )
    end

    let(:added_calendar_raw) do
      GSuite::Raw::Calendar.new(
        id:          added_id,
        summary:     added_id,
        primary:     true,
        access_role: "whatever"
      )
    end

    let(:readded_calendar_raw) do
      GSuite::Raw::Calendar.new(
        id:          readded_id,
        summary:     readded_id,
        primary:     true,
        access_role: "whatever"
      )
    end

    let(:google_client) do
      instance_double(
        GSuite::Client,
        credentials:     Google::Auth::UserRefreshCredentials.new,
        fetch_calendars: ["abc", [modified_calendar_raw, added_calendar_raw, readded_calendar_raw]]
      ).as_null_object
    end

    it("asks GMail to fetch the GMail calendars for the user") do
      expect(google_client).to(have_received(:fetch_calendars))
    end

    it("computes changes to modified calendar instances") do
      instance = GoogleCalendarInstance.find_by(google_calendar_id: modified_calendar.id)
      expect(instance.to_raw).to(eq(modified_calendar_raw))
    end

    it("destroys calendar instances that no longer exist remotely") do
      instance = GoogleCalendarInstance.find_by(google_calendar_id: removed_calendar.id)
      expect(instance).not_to(be_present)
    end

    it("creates calendars that were added remotely, and not already reflected in the system") do
      expect(GoogleCalendar.find_by(google_id: added_id)).to(be_present)
    end
  end
end
