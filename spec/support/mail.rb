# frozen_string_literal: true

module MailHelpers
  extend ActiveSupport::Concern

  included do
    def deliveries
      ActionMailer::Base.deliveries.sort_by(&:subject).map(&:subject)
    end
  end
end

RSpec.configure do |config|
  config.include(MailHelpers)
end
