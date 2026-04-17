class Auth::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :google_callback

  def google_callback
    auth = request.env["omniauth.auth"]
    google_uid = auth["uid"]
    email = auth.dig("info", "email")
    name = auth.dig("info", "name")

    user = User.find_by(google_uid: google_uid) ||
           User.find_by(email: email)

    if user
      user.update!(google_uid: google_uid, auth_method: :google)
    else
      user = User.create!(
        google_uid: google_uid,
        email: email,
        name: name,
        auth_method: :google
      )
    end

    session[:user_id] = user.id

    if user.is_admin?
      redirect_to admin_root_path
    elsif user.is_host? && user.host_profile&.active?
      redirect_to host_dashboard_path
    else
      redirect_to root_path
    end
  end
end
