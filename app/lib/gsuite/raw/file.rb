# frozen_string_literal: true

# A simplified representation of a file in Google Drive, as returned by Google.
GSuite::Raw::File =
  Struct.new(
    :id,
    :mime_type,
    :name,
    :parent_id,
    :permissions,
    :capabilities,
    :quota_size,
    :shared,
    :spaces,
    :starred,
    :trashed,
    :shortcut,
    :web_view_link
  ) do
    def initialize( # rubocop:disable Metrics/ParameterLists
      id:,
      mime_type:,
      name:,
      capabilities:,
      spaces:,
      web_view_link:,
      parent_id: nil,
      permissions: nil,
      quota_size: nil,
      shared: nil,
      starred: nil,
      trashed: nil,
      shortcut: nil
    )
      capabilities ||= {}
      capabilities.reject! { |_, v| !v }
      capabilities = capabilities.to_a.sort.to_h

      super(id,
            mime_type,
            name,
            parent_id,
            permissions || [],
            capabilities,
            quota_size || 0,
            !!shared,
            spaces,
            !!starred,
            !!trashed,
            shortcut,
            web_view_link)
    end

    def self.from_google(gfile)
      raise "File #{gfile.id} has more than one parent!" if (gfile.parents || []).length > 1

      GSuite::Raw::File.new(
        id:            gfile.id,
        mime_type:     gfile.mime_type,
        name:          gfile.name,
        parent_id:     gfile.parents&.first,
        permissions:   gfile.permissions&.map { |perm| GSuite::Raw::Permission.from_google(perm) },
        capabilities:  gfile.capabilities&.to_h,
        quota_size:    gfile.quota_bytes_used,
        shared:        gfile.shared,
        spaces:        gfile.spaces,
        starred:       gfile.starred,
        trashed:       gfile.trashed,
        shortcut:      gfile.shortcut_details&.to_h,
        web_view_link: gfile.web_view_link
      )
    end
  end
