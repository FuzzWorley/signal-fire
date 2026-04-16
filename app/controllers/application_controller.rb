class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||=
      if (token = bearer_token)
        payload = JwtService.decode(token)
        User.find_by(id: payload[:user_id]) if payload
      elsif session[:user_id]
        User.find_by(id: session[:user_id])
      end
  end

  def signed_in?
    current_user.present?
  end

  def authenticate!
    render json: { error: "Unauthorized" }, status: :unauthorized unless signed_in?
  end

  def require_admin!
    render json: { error: "Forbidden" }, status: :forbidden unless current_user&.admin?
  end

  def api_request?
    request.format.json? || request.headers["Accept"]&.include?("application/json")
  end

  def bearer_token
    header = request.headers["Authorization"]
    header&.start_with?("Bearer ") ? header.delete_prefix("Bearer ") : nil
  end
end
