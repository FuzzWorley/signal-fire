class Api::V1::Auth::SessionsController < ActionController::API
  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: { token: token, user: user_json(user) }
    else
      render json: { error: "Invalid email or password." }, status: :unauthorized
    end
  end

  def destroy
    # JWT is stateless — client discards the token. Nothing to do server-side.
    head :no_content
  end

  private

  def user_json(user)
    user.slice(:id, :name, :email, :is_host, :is_admin)
  end
end
