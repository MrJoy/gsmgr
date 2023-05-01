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

  MAX_LEN = 50
  fmt_array = ->(val) { val&.join("<br>\n")&.html_safe } # rubocop:disable Rails/OutputSafety
  trim_text = ->(val) { (val || "").length > MAX_LEN ? "#{val&.truncate(MAX_LEN)}..." : val }

  field :id, as: :id, link_to_resource: true

  field :google_id,                as: :text, hide_on: %i[new edit]
  field :email,                    as: :text, hide_on: %i[new edit], sortable: true
  field :scopes,                   as: :text, hide_on: %i[index new edit], format_using: fmt_array
  field :contact_sync_token,       as: :text, hide_on: %i[index new edit], format_using: trim_text
  field :contact_group_sync_token, as: :text, hide_on: %i[index new edit], format_using: trim_text

  field :calendar_instances, as: :has_many, hide_on: %i[new edit]
  field :contact_groups,     as: :has_many, hide_on: %i[new edit]
  field :contacts,           as: :has_many, hide_on: %i[new edit]
end
