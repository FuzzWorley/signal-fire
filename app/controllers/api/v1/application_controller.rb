class Api::V1::ApplicationController < ActionController::API
  before_action :authenticate_api_user!

  private

  def optionally_authenticate_api_user!
    token = bearer_token
    return unless token

    payload = JwtService.decode(token)
    return unless payload

    @current_user = User.find_by(id: payload[:user_id])
  end

  def authenticate_api_user!
    token = bearer_token
    unless token
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    payload = JwtService.decode(token)
    unless payload
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    @current_user = User.find_by(id: payload[:user_id])
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def bearer_token
    header = request.headers["Authorization"]
    header&.start_with?("Bearer ") ? header.delete_prefix("Bearer ") : nil
  end
end
