require 'jwt'

module TokenHelper
  def generate_token(payload)
    secret_key = ENV['JWT_SECRET_KEY']
    JWT.encode(payload, secret_key, 'HS256')
  end
end
