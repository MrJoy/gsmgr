# frozen_string_literal: true

# Avo resource for `GoogleFile`.
#
class GoogleFileResource < Avo::BaseResource
  self.title              = :name
  self.includes           = %i[parent]
  self.record_selector    = false
  self.visible_on_sidebar = true

  fmt_array = ->(val) { val&.join("<br>\n")&.html_safe } # rubocop:disable Rails/OutputSafety

  heading "Metadata"
  field :id,        as: :id
  field :google_id, as: :text, readonly: true, hide_on: %i[index]

  heading "Details"
  field :parent_id,     as: :text,       readonly: true, hide_on: %i[index]
  field :parent,        as: :belongs_to, readonly: true, sortable: ->(q, dir) { q.order(parent_id: dir) } # rubocop:disable Layout/LineLength
  field :name,          as: :text,    readonly: true,                     sortable: true
  field :mime_type,     as: :text,    readonly: true, hide_on: %i[index], sortable: true
  field :quota_size,    as: :number,  readonly: true,                     sortable: true
  field :owner,         as: :text,    readonly: true,                     sortable: true
  field :shared,        as: :boolean, readonly: true,                     sortable: true
  field :starred,       as: :boolean, readonly: true,                     sortable: true
  field :trashed,       as: :boolean, readonly: true,                     sortable: true
  field :spaces,        as: :text,    readonly: true, hide_on: %i[index], format_using: fmt_array
  field :capabilities,
        as:           :text,
        readonly:     true,
        hide_on:      %i[index],
        format_using: lambda { |val|
          html =
            ["<dl class=\"capabilities\">"] +
            val&.map { |k, v| "<dt>#{k}</dt><dd>#{v}</dd>" } +
            ["</dl>"]
          html.join.html_safe # rubocop:disable Rails/OutputSafety
        }
  field :shortcut,      as: :text,    readonly: true, hide_on: %i[index]
  field :web_view_link, as: :text,    readonly: true, hide_on: %i[index], format_using: ->(val) { link_to(val, val, target: "_blank", rel: "noopener") } # rubocop:disable Layout/LineLength

  field :allowances,  as: :has_many,   readonly: true
  field :account,     as: :belongs_to, readonly: true
  field :permissions, as: :has_many,   readonly: true
  field :children,    as: :has_many,   readonly: true

  filter AnyoneWithLink
end
