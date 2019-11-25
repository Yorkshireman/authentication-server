require_relative '../helpers/token_helper'

class UsersController < ApplicationController
  include TokenHelper
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  def signin
    user = User.find_by(email: user_params([:email, :password])[:email])
    unless user&.authenticate(params[:user][:password])
      response.status = 401
      return render json: {
        errors: [
          { title: 'Incorrect email/password.' }
        ]
      }
    end

    token = generate_token({ exp: (Time.now + 1800).to_i, user_id: user.id })
    render json: {
      data: {
        token: token
      }
    }
  end

  def signup
    user = User.new(user_params([:email, :name, :password]))
    return unless user.save

    token = generate_token({ exp: (Time.now + 1800).to_i, user_id: user.id })
    response.status = 201
    render json: {
      data: {
        token: token
      }
    }
  end

  private

  def missing_parameter
    response.status = 400
    render json: {
      errors: [
        { title: 'Missing parameter(s).' }
      ]
    }
  end

  def user_params(required_params)
    params.require(:user).permit(:email, :name, :password).tap do |user_params|
      user_params.require(required_params)
    end
  end
end
