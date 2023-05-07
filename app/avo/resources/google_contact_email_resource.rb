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

  heading "Metadata"
  field :id, as: :id, link_to_resource: true

  heading "Details"
  field :email, as: :text, readonly: true, sortable: true

  field :contact, as: :belongs_to, readonly: true
end
