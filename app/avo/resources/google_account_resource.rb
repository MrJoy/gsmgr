# frozen_string_literal: true

# Avo resource for `GoogleAccount`.
#
# rubocop:disable Layout/LineLength
class GoogleAccountResource < Avo::BaseResource
  self.title           = :email
  self.includes        = %i[]
  self.record_selector = false

  self.show_controls =
    lambda do
      back_button
      action(SyncGoogleCalendars, style: :primary, color: :green)
      action(SyncGoogleContacts, style: :primary, color: :green)
      action(SyncGoogleDrive, style: :primary, color: :green)
    end

  action SyncGoogleCalendars
  action SyncGoogleContacts
  action SyncGoogleDrive

  MAX_LEN = 40
  fmt_array = ->(val) { val&.join("<br>\n")&.html_safe } # rubocop:disable Rails/OutputSafety
  trim_text = ->(val) { val&.truncate(MAX_LEN) }
  size      = ->(val) { view_context.number_to_human_size(val) }

  heading "Metadata"
  field :id,        as: :id, link_to_resource: true
  field :google_id, as: :text, readonly: true

  heading "Details"
  field :email, as: :text, readonly: true, sortable: true

  heading "Permissions"
  field :scopes, as: :text, readonly: true, hide_on: %i[index], format_using: fmt_array

  heading "Storage"
  field :storage_limit,             as: :number, readonly: true, hide_on: %i[index], format_using: size, name: "Limit"
  field :storage_total_usage,       as: :number, readonly: true, hide_on: %i[index], format_using: size, name: "Total Usage"
  field :storage_drive_usage,       as: :number, readonly: true, hide_on: %i[index], format_using: size, name: "Drive"
  field :storage_drive_trash_usage, as: :number, readonly: true, hide_on: %i[index], format_using: size, name: "Trash (Drive)"

  heading "Sync Tokens"
  field :contact_sync_token,       as: :text, readonly: true, hide_on: %i[index], format_using: trim_text
  field :contact_group_sync_token, as: :text, readonly: true, hide_on: %i[index], format_using: trim_text

  field :calendar_instances, as: :has_many, readonly: true
  field :contact_groups,     as: :has_many, readonly: true
  field :contacts,           as: :has_many, readonly: true
end
# rubocop:enable Layout/LineLength
