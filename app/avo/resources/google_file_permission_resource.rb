# frozen_string_literal: true

# Avo resource for `GoogleFilePermission`.
#
class GoogleFilePermissionResource < Avo::BaseResource
  self.title              = :email_address
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  heading "Metadata"
  field :id,        as: :id
  field :google_id, as: :text, readonly: true

  heading "Details"
  field :email_address,        as: :text,    readonly: true, sortable: true
  field :target_type,          as: :text,    readonly: true, hide_on: %i[index]
  field :deleted,              as: :boolean, readonly: true, hide_on: %i[index]
  field :role,                 as: :text,    readonly: true, sortable: true
  field :allow_file_discovery, as: :boolean, readonly: true, hide_on: %i[index]
  field :pending_owner,        as: :boolean, readonly: true, hide_on: %i[index]

  field :account, as: :belongs_to, readonly: true
  field :file,    as: :belongs_to, readonly: true
end
