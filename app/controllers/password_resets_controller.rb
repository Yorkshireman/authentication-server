require_relative '../helpers/token_helper'

# decoded_token = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
class PasswordResetsController < ActionController::Base
  include TokenHelper

  def create
    email = params.require(:email)
    user = User.find_by(email: email)
    return unless user

    token = generate_token({ exp: (Time.now + 7200).to_i, user_id: user.id })
    PasswordResetMailer.with(email: user.email, token: token).password_reset_email.deliver_now
  end

  def edit
    @token = params[:token]
    puts @token
  end

  def update
    puts '------------ hello from update'
  end
end
