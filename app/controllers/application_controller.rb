class ApplicationController < ActionController::Base
  allow_browser versions: :modern if Rails.env.production?
  stale_when_importmap_changes

  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def require_host!
    unless current_user&.is_host? && current_user&.host_profile&.active?
      redirect_to host_login_path, alert: "Please sign in to access the host dashboard."
    end
  end

  def require_admin!
    unless current_user&.is_admin?
      redirect_to admin_login_path, alert: "Please sign in as an admin."
    end
  end
end
