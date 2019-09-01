require 'rails_helper'

RSpec.describe 'GET / response', type: :request do
  before :each do
    headers = {
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }

    get '/', headers: headers
  end

  it 'has correct Content-Type header value' do
    expect(response.content_type).to eq('application/vnd.api+json')
  end

  it 'has 200 status code' do
    expect(response).to have_http_status(200)
  end

  # However, we won't do this for actual responses - JSON API Spec dictates not sending
  # messages like this at all really, but defo not inside a data object which should be reserved for resources
  it 'has correct body' do
    expected_json = JSON.generate({
      data: {
        message: 'Hello World'
      }
    })

    expect(response.body).to eq(expected_json)
  end
end
