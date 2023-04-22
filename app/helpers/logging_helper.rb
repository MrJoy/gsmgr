# frozen_string_literal: true

# Helpers for logging-related functionality that might appear in multiple places.
module LoggingHelper
  def log_exception(exc)
    msg = "#{exc.class}: #{exc.message}"
    trace = exc&.backtrace&.join("\n")
    trace = "\n#{trace}" if trace
    msg += trace if trace

    # Calling `Rails.` explicitly because we may not be in a context that has a logger accessor.
    Rails.logger.error(msg)
  end
end
