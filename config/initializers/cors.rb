Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      *Rails.env.development? ? [
        "http://localhost:8081",  # Expo web dev server
        "http://localhost:19006", # Expo web (older versions)
        /\Aexp:\/\//              # Expo Go on device
      ] : [
        ENV.fetch("MOBILE_APP_ORIGIN", "https://signalfire.app")
      ]
    )

    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head],
      expose: ["Authorization"]
  end
end
