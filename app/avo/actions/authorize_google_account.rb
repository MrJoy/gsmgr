# frozen_string_literal: true

# Send user through OAuth flow.
class AuthorizeGoogleAccount < Avo::BaseAction
  self.name    = "Authorize"
  self.visible = -> { view == :show }

  def handle(**args)
    models, = args.values_at(:models)

    unless models&.length == 1
      error("You must authorize exactly one account at a time.")
      return
    end

    model  = models.first
    target = view_context.resources_google_account_path(model.id)

    redirect_to(main_app.auth_google_authorize_path(target:, hint: model.email))
    silent
  end
end
