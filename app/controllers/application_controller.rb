class ApplicationController < ActionController::API
  before_action :set_headers

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end
end
