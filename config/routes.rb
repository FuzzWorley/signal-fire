Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Public web — Totem Board (Chunk 3)
  get  "/about",                                      to: "pages#about",                       as: :about
  get  "/t/:slug",                                    to: "totems/boards#show",                as: :totem_board
  get  "/t/:slug/e/:event_slug",                      to: "totems/events#show",                as: :totem_event
  post "/t/:slug/e/:event_slug/check_ins",            to: "totems/check_ins#create",           as: :totem_event_check_ins
  post "/empty_totem_email_captures",                 to: "empty_totem_email_captures#create", as: :empty_totem_email_captures

  # Google OAuth (GET /auth/google_oauth2 is handled by OmniAuth middleware)
  get "/auth/google_oauth2/callback", to: "auth/sessions#google_callback"

  # Placeholder routes — replaced with full implementations in Chunks 4 & 5
  root to: redirect("/host/login")
  get "/host/dashboard", to: redirect("/host/login"), as: :host_dashboard
  get "/admin", to: redirect("/admin/login"), as: :admin_root

  # Host auth
  scope "/host", as: :host do
    get    "login",          to: "auth/host/sessions#new",          as: :login
    post   "login",          to: "auth/host/sessions#create"
    delete "logout",         to: "auth/host/sessions#destroy",      as: :logout
    get    "accept_invite",  to: "auth/host/invitations#edit",      as: :accept_invite
    patch  "accept_invite",  to: "auth/host/invitations#update"
    get    "magic_link",     to: "auth/host/magic_links#new",       as: :magic_link
    post   "magic_link",     to: "auth/host/magic_links#create"
    get    "magic_link/sent", to: "auth/host/magic_links#sent",     as: :magic_link_sent
  end

  # Admin auth
  scope "/admin", as: :admin do
    get    "login",  to: "auth/admin/sessions#new",    as: :login
    post   "login",  to: "auth/admin/sessions#create"
    delete "logout", to: "auth/admin/sessions#destroy", as: :logout
  end

  # Mobile API
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "sign_up",  to: "registrations#create"
        post "sign_in",  to: "sessions#create"
        delete "sign_out", to: "sessions#destroy"
        post "google",   to: "google#create"
        post "apple",    to: "apple#create"
      end
    end
  end
end
