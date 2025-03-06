class PasswordResetsController < ActionController::Base
  def edit
    @token = params[:token]
  end

  def success; end
end
