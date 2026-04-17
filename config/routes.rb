Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Google OAuth (GET /auth/google_oauth2 is handled by OmniAuth middleware)
  get "/auth/google_oauth2/callback", to: "auth/sessions#google_callback"

  delete "/auth/logout", to: "auth/sessions#destroy"
end
