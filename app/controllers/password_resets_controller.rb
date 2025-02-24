require_relative '../helpers/token_helper'

class PasswordResetsController < ActionController::Base
  include TokenHelper
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    email = params.require(:email)
    user = User.find_by(email: email)
    if user.nil? then return head :no_content end

    token = generate_token({ exp: (Time.now + 7200).to_i, issued_at: Time.now, user_id: user.id })
    PasswordResetMailer.with(email: user.email, token: token).password_reset_email.deliver_now
    head :no_content
  end

  def edit
    @token = params[:token]
    puts @token
  end

  def update
    decoded_token = JWT.decode(params[:token], ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
    puts decoded_token
    # may want a granular error response for token expiration scenario
    user = User.find(decoded_token[0]['user_id'])
    # if token's issued_at is before password_changed_at, return an error
    # should check if password is same as old one? Maybe not cos why shouldn't we let them do that?
    user.update(password: params[:password])
  end
end
