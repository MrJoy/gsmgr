# frozen_string_literal: true

module GSuiteHelpers
  def event_date_time(d_t)
    Google::Apis::CalendarV3::EventDateTime.new(date_time: d_t)
  end
end

RSpec.configure do |config|
  config.include(GSuiteHelpers)
end
