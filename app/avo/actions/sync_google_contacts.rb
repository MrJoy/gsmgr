# frozen_string_literal: true

# Run the GoogleContactSync command.
class SyncGoogleContacts < Avo::BaseAction
  self.name = "Sync Contacts"

  def handle(**args)
    models, = args.values_at(:models)

    errors = []
    models.each do |model|
      GoogleContactSync.call(model.id)
    rescue StandardError => e
      errors << "#{model.id}: #{e.message}"
    end

    if errors.any?
      error("Errors:<br>\n#{errors.join("<br>\n")}".html_safe) # rubocop:disable Rails/OutputSafety
    else
      succeed("Synced contacts.")
    end
  end
end
