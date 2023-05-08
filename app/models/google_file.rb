# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_files
#
#  id                :bigint           not null, primary key
#  capabilities      :jsonb            not null
#  name              :string           not null
#  owner             :string           not null
#  quota_size        :bigint           not null
#  shared            :boolean          not null
#  shortcut          :jsonb
#  spaces            :string           default([]), not null, is an Array
#  stared            :boolean          not null
#  trashed           :boolean          not null
#  web_view_link     :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  google_account_id :bigint           not null
#  google_id         :string           not null
#  parent_id         :bigint
#
# Indexes
#
#  index_google_files_on_google_account_id_and_google_id  (google_account_id,google_id) UNIQUE
#  index_google_files_on_parent_id                        (parent_id)
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a GSuite contact.
class GoogleFile < ApplicationRecord
  belongs_to :account,
             class_name:  "GoogleAccount",
             foreign_key: :google_account_id,
             dependent:   :destroy,
             inverse_of:  :files

  belongs_to :parent,
             class_name: "GoogleFile",
             inverse_of: :children

  has_many :children,
           class_name:  "GoogleFile",
           foreign_key: :parent_id,
           dependent:   :destroy,
           inverse_of:  :parent

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :permissions,
                          class_name:              "GoogleFilePermission",
                          association_foreign_key: "google_file_permission_id"
  # rubocop:enable Rails/HasAndBelongsToMany

  validates :google_id,
            presence:   true,
            uniqueness: { scope: :google_account_id, case_sensitive: false, on: :create }
end
