class AddCanonicalEmails < ActiveRecord::Migration[7.0]
  def up
    add_column :google_contact_emails, :raw_email, :string
    execute "UPDATE google_contact_emails SET raw_email = email"
    change_column_null :google_contact_emails, :raw_email, false
  end

  def down
    remove_column :google_contact_emails, :raw_email
  end
end
