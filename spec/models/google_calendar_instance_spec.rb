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

require "rails_helper"

RSpec.describe(GoogleCalendarInstance) do
  context("when validating") do
    subject { build(:google_calendar_instance) }

    it { is_expected.to(validate_presence_of(:summary)) }

    # NOTE: The following test is disabled per a warning from shoulda-matchers.  tl;dr: Because
    # values are auto-coerced in boolean columns, this test is kinda meaningless.
    # it { is_expected.to(validate_inclusion_of(:primary).in_array([true, false])) }
    it { is_expected.to(validate_presence_of(:access_role)) }
  end

  describe("#to_raw") do
    subject { calendar_instance.to_raw }

    let(:reminder) { ActiveSupport::HashWithIndifferentAccess.new(minutes: 10, channel: "popup") }

    let(:calendar_instance) do
      described_class.find(create(:google_calendar_instance).id)
    end

    # rubocop:disable RSpec/NamedSubject
    it("returns a valid GSuite::Raw::Calendar") do
      expect(subject).to(eql(
                           GSuite::Raw::Calendar.new(
                             id:          calendar_instance.calendar.google_id,
                             summary:     calendar_instance.summary,
                             primary:     calendar_instance.primary,
                             access_role: calendar_instance.access_role
                           )
                         ))
    end
    # rubocop:enable RSpec/NamedSubject
  end

  describe("#from_raw") do
    subject(:model_object) do
      build(:google_calendar_instance, calendar:, account:)
    end

    let!(:account) { build(:google_account) }
    let(:model_google_id) { nil }
    let(:raw_google_id)   { "foo@bar.com" }
    let(:raw_object) do
      GSuite::Raw::Calendar.new(
        id:          calendar.google_id,
        summary:     raw_google_id,
        primary:     false,
        access_role: "something_new"
      )
    end
    let!(:calendar) { build(:google_calendar, google_id: model_google_id) }

    context("with a new model object") do
      it("accepts updates from the raw object") do
        model_object.from_raw(raw_object, calendar.id)
        expect(model_object.to_raw).to(eql(raw_object))
      end
    end
  end
end
