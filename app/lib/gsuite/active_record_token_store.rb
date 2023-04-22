# frozen_string_literal: true

# Mechanism for persistent Google OAuth tokens in Postgres.
class GSuite::ActiveRecordTokenStore < Google::Auth::TokenStore
  def fetch(id)
    GoogleToken.where(google_id: id).first
  end

  def load(id)
    rec = fetch(id)
    rec&.token
  end

  def store(id, token)
    rec = fetch(id)
    if rec
      rec.token = token
      rec.save!
    else
      rec = GoogleToken.create!(google_id: id, token:)
    end

    rec
  end

  def delete(id)
    GoogleToken.where(google_id: id).delete_all
  end
end
