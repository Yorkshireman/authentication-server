require_relative '../helpers/token_helper'

class UsersController < ApplicationController
  include TokenHelper
  def signup
    # validate params
    user = User.new(user_params)
    # rubocop: disable Style/GuardClause
    if user.save
      response.status = 201
      token = generate_token({ user_id: user.id })
      render json: {
        data: {
          token: token
        }
      }
    end
    # rubocop: enable Style/GuardClause
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :password).tap do |user_params|
      user_params.require([:email, :name, :password])
    end
  end
end
