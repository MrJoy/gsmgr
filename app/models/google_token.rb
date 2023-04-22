# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective,Layout/LineLength
# == Schema Information
#
# Table name: google_tokens
#
#  id         :bigint           not null, primary key
#  token      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  google_id  :string           not null
#
# Indexes
#
#  index_google_tokens_on_google_id  (google_id) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective,Layout/LineLength

# Represents a Google OAuth token.
class GoogleToken < ApplicationRecord
  encrypts :token
end
