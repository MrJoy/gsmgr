# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :auth do
    get "google/authorize"
    get "google/callback" # N.B. must be in sync with google_controller.rb, and GCP!
    get "google/done"
  end

  root to: "static#root"
end
