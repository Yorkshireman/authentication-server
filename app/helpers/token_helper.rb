require 'jwt'

module TokenHelper
  def generate_token(payload)
    secret_key = ENV['JWT_SECRET_KEY'] # can this be moved into config so it's less expensive?
    JWT.encode(payload, secret_key, 'HS256')
  end

  def decode_token(token)
    secret_key = ENV['JWT_SECRET_KEY'] # can this be moved into config so it's less expensive?
    JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
  end
end
