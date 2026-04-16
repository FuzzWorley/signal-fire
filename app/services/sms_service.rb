class SmsService
  def self.send_otp(phone_number, code)
    if Rails.env.production?
      client = Twilio::REST::Client.new(
        Rails.application.credentials.twilio_account_sid,
        Rails.application.credentials.twilio_auth_token
      )
      client.messages.create(
        from: Rails.application.credentials.twilio_phone_number,
        to: phone_number,
        body: "Your Signal Fire verification code is #{code}. Valid for #{PhoneVerification::EXPIRY_MINUTES} minutes."
      )
    else
      Rails.logger.info("[SmsService] OTP for #{phone_number}: #{code}")
    end
  end
end
