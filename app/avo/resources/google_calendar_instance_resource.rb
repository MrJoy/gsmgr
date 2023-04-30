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

  field :id, as: :id, link_to_resource: true

  field :primary,     as: :boolean, hide_on: %i[new edit]
  field :access_role, as: :text,    hide_on: %i[new edit]
  field :summary,     as: :text,    hide_on: %i[new edit], sortable: true

  field :account,  as: :belongs_to, hide_on: %i[new edit]
  field :calendar, as: :belongs_to, hide_on: %i[new edit]
end
