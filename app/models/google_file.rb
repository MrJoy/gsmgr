# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_files
#
#  id                :bigint           not null, primary key
#  capabilities      :jsonb            not null
#  mime_type         :string           default(""), not null
#  name              :string           not null
#  owner             :string           not null
#  quota_size        :bigint           not null
#  shared            :boolean          not null
#  shortcut          :jsonb
#  spaces            :string           default([]), not null, is an Array
#  starred           :boolean          not null
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
             dependent:   false,
             inverse_of:  :files

  belongs_to :parent,
             class_name: "GoogleFile",
             inverse_of: :children,
             dependent:   false,
             optional:   true,
             validate:   false

  has_many :children,
           class_name:  "GoogleFile",
           foreign_key: :parent_id,
           dependent:   false,
           inverse_of:  :parent

  has_many :allowances,
           class_name: "GoogleContactGroupAllowance",
           dependent:  :destroy,
           inverse_of: :file

  has_many :permissions,
           class_name: "GoogleFilePermission",
           dependent:  :destroy,
           inverse_of: :file

  validates :google_id,
            presence:   true,
            uniqueness: { scope: :google_account_id, case_sensitive: false, on: :create }

  scope :anyone_with_link, -> do
    where(id: GoogleFilePermission.where(google_id: "anyoneWithLink").pluck(:google_file_id))
  end

  def link_permission
    permissions.where(target_type: "anyone").first
  end

  def link_access
    link_permission&.role
  end

  def root_folder
    root = parent
    next_parent = root
    while next_parent
      next_parent = next_parent.parent
      root = next_parent if next_parent
    end
    root
  end

  def effective_allowances
    root_folder&.allowances || allowances
  end

  ACCESS_LEVELS = {
    "reader" => 0,
    "commenter" => 1,
    "writer" => 2,
    "owner" => 3,
  }
  ACCESS_LEVELS_REVERSE = ACCESS_LEVELS.invert
  def expected_access_levels
    result = {}
    effective_allowances.includes(contact_group: :contacts).each do |allowance|
      allowance.contact_group.contacts.each do |contact|
        lvl = ACCESS_LEVELS[allowance.access_level]
        result[contact.primary_email] ||= 0
        result[contact.primary_email] = lvl if lvl > result[contact.primary_email]
      end
    end
    result
      .to_a
      .map { |(email, lvl)| [email, ACCESS_LEVELS_REVERSE[lvl]] }
      .sort
  end

  def current_access_levels
    permissions
      .where(target_type: "user",
             role:       %w[reader commenter writer])
      .pluck(:email_address, :role)
      .sort
  end

  def access_level_changes
    result = {}
    current_access_levels.each do |(email, role)|
      result[email] = [role, nil]
    end

    expected_access_levels.each do |(email, role)|
      result[email] ||= [nil, nil]
      result[email][1] = role
    end

    result.to_a.select { |(user, (from, to))| from != to }.sort
  end
end
