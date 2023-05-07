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

  heading "Metadata"
  field :id,        as: :id, link_to_resource: true
  field :google_id, as: :text, readonly: true

  field :calendar_instances, as: :has_many,                               readonly: true
  field :accounts,           as: :has_many, through: :calendar_instances, readonly: true
end
