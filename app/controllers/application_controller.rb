class ApplicationController < ActionController::API
  before_action :set_headers, :validate_headers

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  def validate_headers
    return if request.headers['Authorization']

    response.status = 401
    render json: {
      errors: [
        {
          status: '401',
          title: 'Missing Authorization header'
        }
      ]
    }
  end
end
