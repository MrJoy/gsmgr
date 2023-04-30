# frozen_string_literal: true

# Avo resource for `GoogleContact`.
class GoogleContactResource < Avo::BaseResource
  self.title              = :primary_email
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  self.show_controls =
    lambda do
      back_button
    end

  field :id, as: :id, link_to_resource: true

  field :google_id,               as: :text, hide_on: %i[new edit]
  field :display_name,            as: :text, hide_on: %i[new edit], sortable: true
  field :primary_email,           as: :text, hide_on: %i[new edit], sortable: true
  field :display_name_last_first, as: :text, hide_on: %i[index new edit]
  field :given_name,              as: :text, hide_on: %i[index new edit]
  field :middle_name,             as: :text, hide_on: %i[index new edit]
  field :family_name,             as: :text, hide_on: %i[index new edit]

  field :account, as: :belongs_to, hide_on: %i[new edit]
  field :emails,  as: :has_many,   hide_on: %i[new edit]
end
