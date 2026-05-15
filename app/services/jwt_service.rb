class JwtService
  ALGORITHM = "HS256"
  EXPIRY = 30.days

  def self.encode(payload)
    payload = { exp: EXPIRY.from_now.to_i }.merge(payload)
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, algorithms: [ ALGORITHM ])
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    Rails.application.secret_key_base
  end
end
