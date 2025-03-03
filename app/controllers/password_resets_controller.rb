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
    validate_update_params(update_params)
    decoded_token = JWT.decode(update_params[:token], ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
    # may want a granular error response for token expiration scenario
    user = User.find(decoded_token[0]['user_id'])
    check_if_token_has_already_been_used(user, decoded_token[0]['issued_at'])

    # check if password is same as current one - try to implement in the model
    begin
      user.update!(password: update_params[:password])
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def check_if_token_has_already_been_used(user, token_issue_datetime)
    return unless user.password_changed_at > token_issue_datetime

    response.status = :unprocessable_entity
    render json: {
      errors: [
        # rubocop:disable Layout/LineLength
        'This password reset link has already been used. If you still need to reset your password, please request a new reset link.'
        # rubocop:enable Layout/LineLength
      ]
    }
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

  def validate_update_params(update_params)
    return unless update_params[:password] != update_params[:password_confirmation]

    response.status = :unprocessable_entity
    render json: {
      errors: [
        'Password and password confirmation do not match.'
      ]
    }
  end
end
