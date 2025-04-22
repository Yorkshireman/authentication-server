module Api
  class PasswordResetsController < ActionController::API
    before_action :validate_password_length, only: :update
    include TokenHelper
    MAX_PASSWORD_LENGTH = ENV['MAX_PASSWORD_LENGTH'].presence&.to_i || 64
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

    rescue_from 'JWT::ExpiredSignature' do
      # rubocop:disable Layout/LineLength
      message = 'This password reset link has expired. If you still need to reset your password, please request a new reset link.'
      # rubocop:enable Layout/LineLength
      response.status = :unprocessable_entity
      logger.error message
      render json: { errors: [message] }
    end

    def create
      user = User.find_by(password_reset_create_params)
      if user.nil? then return head :no_content end

      token = generate_token({ exp: (Time.now + 7200).to_i, issued_at: Time.now, user_id: user.id })
      PasswordResetMailer.with(email: user.email, token: token).password_reset_email.deliver_now
      head :no_content
    end

    def update
      update_params = password_reset_update_params
      return unless password_params_match?(update_params)

      user, token_contents = process_token(update_params[:token])
      return unless token_not_used?(user, token_contents['issued_at'])

      begin
        user.update!(password: update_params[:password])
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity and return
      end

      render json: { redirect_url: 'reset-password/success' } and return
    end

    private

    def handle_parameter_missing(exception)
      render json: { errors: [exception.message] }, status: :bad_request
    end

    def handle_record_not_found(exception)
      raise exception unless action_name == 'update'

      render json: {
        errors: ['User not found. Please try again by requesting another password link.']
      }, status: :not_found
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

    def password_reset_create_params
      params.require(:email)
      params.permit(:email)
    end

    def password_reset_update_params
      params.require(:token)
      params.require(:password)
      params.require(:password_confirmation)
      params.permit(:token, :password, :password_confirmation)
    end

    def process_token(token)
      decoded_token = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
      token_contents = decoded_token[0]
      user = User.find(token_contents['user_id'])
      [user, token_contents]
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

    def validate_password_length
      password = password_reset_update_params[:password]
      return unless password && password.length > MAX_PASSWORD_LENGTH

      render json: {
        errors: [
          "Password is too long (maximum is #{MAX_PASSWORD_LENGTH} characters)"
        ]
      }, status: :unprocessable_entity
    end
  end
end
