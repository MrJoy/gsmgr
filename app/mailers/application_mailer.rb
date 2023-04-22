# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  helper :application

  default from: "noreply@localhost"
end
