# frozen_string_literal: true

# Avo resource for `GoogleAccount`.
class GoogleAccountResource < Avo::BaseResource
  self.title           = :email
  self.includes        = %i[]
  self.record_selector = false

  self.show_controls =
    lambda do
      back_button
      action(SyncGoogleCalendars, style: :primary, color: :green)
      action(SyncGoogleContacts, style: :primary, color: :green)
    end

  action SyncGoogleCalendars
  action SyncGoogleContacts

  MAX_LEN = 40
  fmt_array = ->(val) { val&.join("<br>\n")&.html_safe } # rubocop:disable Rails/OutputSafety
  trim_text = ->(val) { val&.truncate(MAX_LEN) }

  heading "Metadata"
  field :id,        as: :id, link_to_resource: true
  field :google_id, as: :text, readonly: true

  heading "Details"
  field :email, as: :text, readonly: true, sortable: true

  heading "Permissions"
  field :scopes, as: :text, readonly: true, hide_on: %i[index], format_using: fmt_array

  heading "Sync Tokens"
  field :contact_sync_token,       as: :text, readonly: true, hide_on: %i[index], format_using: trim_text
  field :contact_group_sync_token, as: :text, readonly: true, hide_on: %i[index], format_using: trim_text

  field :calendar_instances, as: :has_many, readonly: true
  field :contact_groups,     as: :has_many, readonly: true
  field :contacts,           as: :has_many, readonly: true
end
