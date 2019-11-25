require_relative '../helpers/token_helper'

class UsersController < ApplicationController
  include TokenHelper
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  def signin
    User.find_by(email: user_params([:email, :password])[:email]).then do |user|
      unless user&.authenticate(params[:user][:password])
        return render_error_response(401, 'Incorrect email/password.')
      end

      render_success_response(200, user.id)
    end
  end

  def signup
    User.new(user_params([:email, :name, :password])).then do |user|
      render_success_response(201, user.id) if user.save
    end
  end

  private

  def render_error_response(status, message)
    response.status = status
    render json: {
      errors: [
        { title: message }
      ]
    }
  end

  def render_parameter_missing
    render_error_response(400, 'Missing parameter(s).')
  end

  def render_success_response(status, user_id)
    response.status = status
    generate_token({ exp: (Time.now + 1800).to_i, user_id: user_id }).then do |token|
      render json: {
        data: {
          token: token
        }
      }
    end
  end

  def user_params(required_params)
    params.require(:user).permit(:email, :name, :password).tap do |user_params|
      user_params.require(required_params)
    end
  end
end
