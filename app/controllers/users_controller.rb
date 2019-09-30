require_relative '../helpers/token_helper'

class UsersController < ApplicationController
  include TokenHelper
  def signup
    # validate params
    user = User.new(email: params[:email], name: params[:name], password: params[:password])
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
end
