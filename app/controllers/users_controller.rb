class UsersController < ApplicationController
  def signup
    response.status = 201
    render json: {
      data: {
        token: 'foo'
      }
    }
  end
end
