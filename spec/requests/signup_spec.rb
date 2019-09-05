require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  before :each do
    headers = {
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }

    post '/signup', headers: headers
  end

  it 'has correct Content-Type header value' do
    expect(response.content_type).to eq('application/vnd.api+json')
  end

  it 'has 201 status code' do
    expect(response).to have_http_status(201)
  end

  it 'has correct token' do
    expected_token = 'foo' # need to generate this somehow
    expect(JSON.parse(response.body)['data']['token']).to eq(expected_token)
  end
end
