class Api::V1::Auth::AppleController < ActionController::API
  def create
    render json: { error: "Apple login coming soon" }, status: :not_implemented
  end
end
