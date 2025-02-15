class PasswordResetsController < ApplicationController
  def create
    # this route should take an email address as a parameter and check whether or not it exists
    # if it does, it should send an email to that address with a link to the edit route
    email = params.require(:email)
    user = User.find_by(email: email)
    puts user
  end

  def edit; end

  def update; end
end
