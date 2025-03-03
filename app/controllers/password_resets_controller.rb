require_relative '../helpers/token_helper'

class PasswordResetsController < ActionController::Base
  include TokenHelper
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  rescue_from 'JWT::ExpiredSignature' do
    # rubocop:disable Layout/LineLength
    message = 'This password reset link has expired. If you still need to reset your password, please request a new reset link.'
    # rubocop:enable Layout/LineLength
    response.status = :unprocessable_entity
    logger.error message
    render json: { errors: [message] }
  end

  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    user = User.find_by(email: password_reset_create_params)
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
    validate_update_params
    decoded_token = JWT.decode(params[:token], ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
    # may want a granular error response for token expiration scenario
    user = User.find(decoded_token[0]['user_id'])

    if user.password_changed_at > decoded_token[0]['issued_at']
      response.status = :unprocessable_entity
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

  private

  def handle_parameter_missing(exception)
    render json: { errors: [exception.message] }, status: :bad_request
  end

  def password_reset_create_params
    params.require(:email)
  end

  def validate_update_params
    params.require(:token)
    params.require(:password)
    params.require(:password_confirmation)
    return unless params[:password] != params[:password_confirmation]

    response.status = :unprocessable_entity
    render json: {
      errors: [
        'Password and password confirmation do not match.'
      ]
    }
  end
end
