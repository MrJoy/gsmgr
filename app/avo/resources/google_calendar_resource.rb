# frozen_string_literal: true

# Avo resource for `GoogleCalendar`.
class GoogleCalendarResource < Avo::BaseResource
  self.title           = :google_id
  self.includes        = %i[]
  self.record_selector = false

  self.show_controls =
    lambda do
      back_button
    end

  field :id, as: :id, link_to_resource: true

  field :google_id, as: :text, hide_on: %i[new edit]

  field :calendar_instances, as: :has_many,                               hide_on: %i[new edit]
  field :accounts,           as: :has_many, through: :calendar_instances, hide_on: %i[new edit]
end
