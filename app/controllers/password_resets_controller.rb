require_relative '../helpers/token_helper'

class PasswordResetsController < ActionController::Base
  include TokenHelper
  skip_before_action :verify_authenticity_token, only: [:create]

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
    decoded_token = JWT.decode(params[:token], ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
    # may want a granular error response for token expiration scenario
    user = User.find(decoded_token[0]['user_id'])
    user.update(password: params[:password])
    # update db for "password changed"? Might have done this automatically already
    # invalidate the token
  end
end
