require_relative '../helpers/token_helper'

class UsersController < ApplicationController
  include TokenHelper
  # rubocop: disable Style/GuardClause
  def signup
    user = User.new(user_params)
    if user.save
      response.status = 201
      token = generate_token({ exp: (Time.now + 1800).to_i, user_id: user.id })
      render json: {
        data: {
          token: token
        }
      }
    end
  end
  # rubocop: enable Style/GuardClause

  private

  def user_params
    params.require(:user).permit(:email, :name, :password).tap do |user_params|
      user_params.require([:email, :name, :password])
    end
  end
end
