# frozen_string_literal: true

# A simplified representation of a file permission in Google Drive, as returned by Google.
GSuite::Raw::Permission =
  Struct.new(
    :id,
    :email_address,
    :deleted,
    :role,
    :type,
    :pending_owner,
    :allow_file_discovery
  ) do
    def initialize( # rubocop:disable Metrics/ParameterLists
      id:,
      role:,
      type:,
      email_address: nil,
      deleted: nil,
      pending_owner: nil,
      allow_file_discovery: nil
    )
      super(id,
            email_address&.downcase,
            deleted,
            role, # writer, reader, owner, commenter
            type, # user, anyone, group
            pending_owner,
            allow_file_discovery)
    end

    # N.B. Some special handling is needed:
    # * `role`: `owner` needs special treatment.  Other values: `reader`, `writer`, `commenter`.
    # * `type`: `anyone`, and `group` need special treatment.
    # * `allow_file_discovery`: Only present when `type=="anyone"`
    def self.from_google(gperm)
      GSuite::Raw::Permission.new(
        id:                   gperm.id,
        email_address:        gperm.email_address,
        role:                 gperm.role,
        deleted:              gperm.deleted,
        type:                 gperm.type,
        pending_owner:        gperm.pending_owner,
        allow_file_discovery: gperm.allow_file_discovery
      )
    end
  end
