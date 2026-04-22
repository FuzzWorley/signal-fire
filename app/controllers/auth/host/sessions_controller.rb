class Auth::Host::SessionsController < ApplicationController
  def new
    redirect_to host_dashboard_path if signed_in? && current_user.is_host?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password]) && user.is_host? && user.host_profile&.active?
      session[:user_id] = user.id
      AnalyticsService.track("host_logged_in", user_id: user.id)
      redirect_to host_dashboard_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to host_login_path
  end
end
