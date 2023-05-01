# frozen_string_literal: true

# A simplified representation of a contact group, as returned by Google.
GSuite::Raw::ContactGroup =
  Struct.new(
    :id,
    :name,
    :formatted_name,
    :group_type,
    :deleted?
  ) do
    def initialize(
      id:,
      name:,
      group_type:,
      formatted_name: nil,
      deleted: false
    )
      super(id,
            name,
            formatted_name || name,
            group_type,
            deleted)
    end

    def self.from_google(google_contact_group)
      GSuite::Raw::ContactGroup.new(
        id:             google_contact_group.resource_name.split("/").last,
        name:           google_contact_group.name,
        formatted_name: google_contact_group.formatted_name,
        group_type:     google_contact_group.group_type,
        deleted:        google_contact_group.metadata&.deleted?
      )
    end
  end
