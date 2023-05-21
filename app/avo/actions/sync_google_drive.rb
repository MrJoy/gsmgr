# frozen_string_literal: true

# Run the GoogleDriveInfoSync command.
class SyncGoogleDrive < Avo::BaseAction
  self.name    = "Sync Drive"
  self.visible = -> { view == :show }

  def handle(**args)
    models, = args.values_at(:models)

    errors = []
    models.each do |model|
      GoogleDriveInfoSync.call(model.id)
      GoogleDriveFilesSync.call(model.id)
    rescue StandardError => e
      errors << "#{model.id}: #{e.message}"
    end

    if errors.any?
      error("Errors:<br>\n#{errors.join("<br>\n")}".html_safe) # rubocop:disable Rails/OutputSafety
    else
      succeed("Synced drive.")
    end
  end
end
