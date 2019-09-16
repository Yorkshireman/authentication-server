class ApplicationController < ActionController::API
  before_action :set_headers, :validate_headers

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  # rubocop:disable Metrics/MethodLength
  def validate_headers
    return if /\ABearer [a-zA-Z0-9]+\.[a-zA-Z0-9]+.[a-zA-Z0-9]+\z/.match?(request.headers['Authorization'])

    response.status = '400'
    render json: {
      errors: [
        {
          status: '400',
          title: if request.headers['Authorization'].nil?
                   'Missing Authorization header'
                 else
                   'Malformed Authorization header'
                 end
        }
      ]
    }
  end
  # rubocop:enable Metrics/MethodLength
end
