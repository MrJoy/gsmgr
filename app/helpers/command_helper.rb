# frozen_string_literal: true

# Various helpers for Command objects.
module CommandHelper
  def client(account)
    GSuite::Client.new(account.id, scopes: account.scopes)
  end

  def account_and_client(account_id, include_cals: false)
    account_scope = GoogleAccount
    account_scope = account_scope.includes(calendars: :calendar_instances) if include_cals
    account       = account_scope.where(id: account_id).first

    return [nil, nil] if account.blank?

    [account, client(account)]
  end

  def logger
    Rails.logger
  end
end
