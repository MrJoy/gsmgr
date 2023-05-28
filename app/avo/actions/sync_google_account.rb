# frozen_string_literal: true

# Fire a GoogleAccountSyncWorker job.
class SyncGoogleAccount < Avo::BaseAction
  self.name    = "Sync Account"
  self.visible = -> { view == :show }

  def handle(**args)
    models, = args.values_at(:models)

    errors = []
    models.each do |model|
      GoogleAccountSyncWorker.perform_async(model.id)
    rescue StandardError => e
      errors << "#{model.id}: #{e.message}"
    end

    if errors.any?
      error("Errors:<br>\n#{errors.join("<br>\n")}".html_safe) # rubocop:disable Rails/OutputSafety
    else
      succeed("Sidekiq jobs fired.  This may take a while.  " \
              "Check status at <a href='http://localhost:3000/sidekiq'>Sidekiq " \
              "Dashboard</a>.".html_safe) # rubocop:disable Rails/OutputSafety
    end
  end
end
