class AddMimeTypeToGoogleFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :google_files, :mime_type, :string, null: false, default: ""
  end
end
