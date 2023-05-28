# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  mount Avo::Engine, at: Avo.configuration.root_path

  mount Sidekiq::Web, at: "/sidekiq"

  namespace :auth do
    get "google/authorize"
    get "google/callback" # N.B. must be in sync with google_controller.rb, and GCP!
    get "google/done"
  end

  root to: "static#root"
end
