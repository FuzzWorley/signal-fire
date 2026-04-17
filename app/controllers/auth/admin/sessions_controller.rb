class Auth::Admin::SessionsController < ApplicationController
  def new
    redirect_to admin_root_path if signed_in? && current_user.is_admin?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password]) && user.is_admin?
      session[:user_id] = user.id
      redirect_to admin_root_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to admin_login_path
  end
end
