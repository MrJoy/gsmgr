# frozen_string_literal: true

# Avo resource for `GoogleCalendarInstance`.
class GoogleCalendarInstanceResource < Avo::BaseResource
  self.title              = :summary
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  self.show_controls =
    lambda do
      back_button
    end

  heading "Metadata"
  field :id, as: :id

  heading "Details"
  field :summary,     as: :text,    readonly: true, sortable: true
  field :primary,     as: :boolean, readonly: true
  field :access_role, as: :text,    readonly: true

  field :account,  as: :belongs_to, readonly: true
  field :calendar, as: :belongs_to, readonly: true
end
