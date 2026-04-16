class Auth::PhoneVerificationsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :api_request?

  def create
    phone_number = params[:phone_number]&.strip
    unless phone_number.match?(/\A\+[1-9]\d{1,14}\z/)
      return render json: { error: "Phone number must be in E.164 format (e.g. +15551234567)" }, status: :unprocessable_entity
    end

    verification = PhoneVerification.generate_for(phone_number)
    SmsService.send_otp(phone_number, verification.code)

    render json: { message: "Verification code sent" }
  end

  def verify
    verification = PhoneVerification.verify(params[:phone_number]&.strip, params[:code]&.strip)

    if verification.nil?
      return render json: { error: "Invalid or expired code" }, status: :unprocessable_entity
    end

    user = User.find_or_create_by!(phone_number: verification.phone_number) do |u|
      u.name = ""
      u.role = "attendee"
    end

    if api_request?
      render json: { token: JwtService.encode(user_id: user.id), user: user.slice(:id, :name, :phone_number) }
    else
      session[:user_id] = user.id
      redirect_to root_path
    end
  end
end
