# frozen_string_literal: true

# Avo resource for `GoogleContactGroupAllowance`.
class GoogleContactGroupAllowanceResource < Avo::BaseResource
  self.title              = :id
  self.includes           = %i[]
  self.record_selector    = false
  self.visible_on_sidebar = false

  field :id, as: :id

  heading "Details"
  field :access_level, as: :select, options: GoogleContactGroupAllowance::ALLOWED_ACCESS_LEVELS

  field :contact_group, as: :belongs_to, show_on: %i[index new edit show]
  field :file,
        as:           :belongs_to,
        show_on:      %i[index new edit show],
        attach_scope: lambda {
                        # N.B. We _want_ this to blow up if someone is trying to create an
                        # allowance without first pinning down the contact group!
                        #
                        # Also, we only want to show root-level folders as options.
                        query
                          .where(google_account_id: parent.contact_group.account.id,
                                 parent_id:         nil,
                                 mime_type:         "application/vnd.google-apps.folder")
                          .order(name: "ASC")
                      }
end
