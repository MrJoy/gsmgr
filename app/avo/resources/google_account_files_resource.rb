# frozen_string_literal: true

# Avo resource for `GoogleFile`, as rendered on the `GoogleAccount` show view.
class GoogleAccountFilesResource < Avo::BaseResource
  self.model_class = GoogleFile

  self.title              = :name
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  field :name,
        as:           :text,
        readonly:     true,
        format_using: -> (value) do
          link_to(model.name, view_context.resources_google_file_path(model))
        end
  field :owner,   as: :text,    readonly: true
  field :shared,  as: :boolean, readonly: true
  field :starred, as: :boolean, readonly: true
  field :trashed, as: :boolean, readonly: true
end
