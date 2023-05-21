# frozen_string_literal: true

# Run the GoogleCalendarSync command.
class SyncGoogleCalendars < Avo::BaseAction
  self.name    = "Sync Calendars"
  self.visible = -> { view == :show }

  def handle(**args)
    models, = args.values_at(:models)

    errors = []
    models.each do |model|
      GoogleCalendarSync.call(model.id)
    rescue StandardError => e
      errors << "#{model.id}: #{e.message}"
    end

    if errors.any?
      error("Errors:<br>\n#{errors.join("<br>\n")}".html_safe) # rubocop:disable Rails/OutputSafety
    else
      succeed("Synced calendars.")
    end
  end
end
