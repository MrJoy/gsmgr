# frozen_string_literal: true

# Avo resource for `GoogleContactGroup`.
class GoogleContactGroupResource < Avo::BaseResource
  self.title              = :name
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  field :id, as: :id, link_to_resource: true

  field :google_id,      as: :text
  field :name,           as: :text
  field :formatted_name, as: :text
  field :group_type,     as: :text

  field :account,  as: :belongs_to
  field :contacts, as: :has_and_belongs_to_many
end
