# frozen_string_literal: true

# A simplified representation of a calendar, as returned by Google.
GSuite::Raw::Calendar =
  Struct.new(:id, :summary, :primary, :access_role) do
    def initialize(id:, summary:, primary:, access_role:)
      super(id, summary, !!primary, access_role)
    end

    def self.from_google(gcal)
      GSuite::Raw::Calendar.new(
        id:          gcal.id,
        summary:     gcal.summary_override || gcal.summary,
        primary:     gcal.primary,
        access_role: gcal.access_role
      )
    end
  end
