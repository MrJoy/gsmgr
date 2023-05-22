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

  heading "Metadata"
  field :id,        as: :id
  field :google_id, as: :text, readonly: true

  heading "Details"
  field :display_name,            as: :text, readonly: true, sortable: true
  field :primary_email,           as: :text, readonly: true, sortable: true
  field :display_name_last_first, as: :text, readonly: true, hide_on: %i[index]
  field :given_name,              as: :text, readonly: true, hide_on: %i[index]
  field :middle_name,             as: :text, readonly: true, hide_on: %i[index]
  field :family_name,             as: :text, readonly: true, hide_on: %i[index]

  field :created_at, as: :date_time, readonly: true, hide_on: %i[index]
  field :updated_at, as: :date_time, readonly: true, hide_on: %i[index]

  field :account,        as: :belongs_to, readonly: true
  field :emails,         as: :has_many,   readonly: true
  field :contact_groups, as: :has_many,   readonly: true
end
