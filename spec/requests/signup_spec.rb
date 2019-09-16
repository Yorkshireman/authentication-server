require 'jwt'
require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /signup', type: :request do
  describe 'response to a valid request' do
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

    describe 'token' do
      it 'is a String' do
        expect(JSON.parse(response.body)['data']['token']).to be_a(String)
      end

      it 'contains correct information' do
        expected_decoded_token = [{ 'user_id' => '1' }, { 'alg' => 'HS256' }]
        actual_decoded_token = JWT.decode(
          JSON.parse(response.body)['data']['token'],
          ENV['JWT_SECRET_KEY'],
          true,
          { algorithm: 'HS256' }
        )

        expect(actual_decoded_token).to eq(expected_decoded_token)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
