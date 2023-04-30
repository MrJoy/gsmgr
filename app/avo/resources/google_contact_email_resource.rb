# frozen_string_literal: true

# Avo resource for `GoogleContactEmail`.
class GoogleContactEmailResource < Avo::BaseResource
  self.title              = :email
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  self.show_controls =
    lambda do
      back_button
    end

  field :id, as: :id, link_to_resource: true

  field :email, as: :text, hide_on: %i[new edit], sortable: true

  field :contact, as: :belongs_to, hide_on: %i[new edit]
end
