# frozen_string_literal: true

# Avo resource for `GoogleContactGroup`.
class GoogleContactGroupResource < Avo::BaseResource
  self.title              = :name
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  field :id, as: :id, link_to_resource: true

  heading "Metadata"
  field :google_id, as: :text, readonly: true

  heading "Details"
  field :name,           as: :text, readonly: true
  field :formatted_name, as: :text, readonly: true
  field :group_type,     as: :text, readonly: true

  field :account,  as: :belongs_to,              readonly: true
  field :contacts, as: :has_and_belongs_to_many, readonly: true
end
