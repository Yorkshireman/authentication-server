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

    if user.password_changed_at > decoded_token[0]['issued_at']
      response.status = :bad_request
      return render json: {
        errors: [
          # rubocop:disable Layout/LineLength
          'This password reset link has already been used. If you still need to reset your password, please request a new reset link.'
          # rubocop:enable Layout/LineLength
        ]
      }
    end
    # check if password is same as current one - try to implement in the model
    begin
      user.update!(password: params[:password])
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
