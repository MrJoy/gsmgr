class FixColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :google_files, :stared, :starred
  end
end
