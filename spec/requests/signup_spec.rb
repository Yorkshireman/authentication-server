require 'jwt'
require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /signup', type: :request do
  describe 'when called with no Authorization header' do
    before :each do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      post '/signup', headers: headers
      # might need a teardown phase to delete any created Users after each test
    end

    it 'responds with 401' do
      expect(response).to have_http_status(401)
    end

    it 'responds with error information in response body' do
      expected_body = JSON.generate({
        errors: [
          {
            status: '401',
            title: 'Missing Authorization header'
          }
        ]
      })

      expect(response.body).to eq(expected_body)
    end
  end

  describe 'response to a valid request' do
    before :each do
      headers = {
        'Authorization' => 'Bearer foobar',
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

    describe 'token' do
      it 'is a String' do
        expect(JSON.parse(response.body)['data']['token']).to be_a(String)
      end

      it 'contains correct information' do
        decoded_token = JWT.decode(
          JSON.parse(response.body)['data']['token'],
          ENV['JWT_SECRET_KEY'],
          true,
          { algorithm: 'HS256' }
        )

        expected_information = [{ 'user_id' => '1' }, { 'alg' => 'HS256' }]
        expect(decoded_token).to eq(expected_information)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
