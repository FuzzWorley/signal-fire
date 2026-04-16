class Auth::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :google_callback

  def google_callback
    auth = request.env["omniauth.auth"]

    user = User.find_by(google_uid: auth["uid"]) ||
           User.find_by(email: auth.dig("info", "email")) ||
           User.new

    user.assign_attributes(
      google_uid: auth["uid"],
      email: auth.dig("info", "email"),
      name: user.name.presence || auth.dig("info", "name") || ""
    )
    user.save!

    if api_request?
      render json: { token: JwtService.encode(user_id: user.id), user: user.slice(:id, :name, :email) }
    else
      session[:user_id] = user.id
      redirect_to root_path
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
