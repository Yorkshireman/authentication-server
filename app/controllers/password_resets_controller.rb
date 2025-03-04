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
    update_params = password_reset_update_params
    return unless password_params_match?(update_params)

    token_contents = decode_password_reset_token(update_params[:token])[0]
    user = User.find(token_contents['user_id'])
    return unless token_not_used?(user, token_contents['issued_at'])

    update_user_password(user, update_params)
  end

  private

  def decode_password_reset_token(token)
    JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def handle_parameter_missing(exception)
    render json: { errors: [exception.message] }, status: :bad_request
  end

  def password_reset_create_params
    params.require(:email)
  end

  def password_reset_update_params
    params.require(:token)
    params.require(:password)
    params.require(:password_confirmation)
    params.permit(:token, :password, :password_confirmation)
  end

  def token_not_used?(user, token_issue_datetime)
    if user.password_changed_at > token_issue_datetime
      response.status = :unprocessable_entity
      render json: {
        errors: [
          # rubocop:disable Layout/LineLength
          'This password reset link has already been used. If you still need to reset your password, please request a new reset link.'
          # rubocop:enable Layout/LineLength
        ]
      }

      return false
    end

    true
  end

  def update_user_password(user, update_params)
    user.update!(password: update_params[:password])
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def password_params_match?(update_params)
    if update_params[:password] != update_params[:password_confirmation]
      response.status = :unprocessable_entity
      render json: {
        errors: [
          'Password and password confirmation do not match.'
        ]
      }

      return false
    end

    true
  end
end
