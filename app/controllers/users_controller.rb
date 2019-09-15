require_relative '../helpers/token_helper'

class UsersController < ApplicationController
  include TokenHelper
  def signup
    # validate params
    # create user
    # get user id
    response.status = 201
    token = generate_token({ user_id: '1' })
    render json: {
      data: {
        token: token
      }
    }
  end
end
