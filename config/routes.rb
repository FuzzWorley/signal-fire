Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Phone OTP auth
  post "/auth/phone", to: "auth/phone_verifications#create"
  post "/auth/phone/verify", to: "auth/phone_verifications#verify"

  # Google OAuth (GET /auth/google_oauth2 is handled by OmniAuth middleware)
  get "/auth/google_oauth2/callback", to: "auth/sessions#google_callback"

  delete "/auth/logout", to: "auth/sessions#destroy"
end
