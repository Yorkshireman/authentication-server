class ApplicationController < ActionController::API
  before_action :set_headers

  def index
    render json: {
      data: {
        message: 'Hello World'
      }
    }
  end

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end
end
