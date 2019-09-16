require 'jwt'
require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /signup', type: :request do
  describe 'when called without an Authorization header' do
    before :each do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      post '/signup', headers: headers
      # might need a teardown phase to delete any created Users after each test
    end

    it 'responds with 400' do
      expect(response).to have_http_status(400)
    end

    it 'responds with error information in response body' do
      expected_body = JSON.generate({
        errors: [
          {
            status: '400',
            title: 'Missing Authorization header'
          }
        ]
      })

      expect(response.body).to eq(expected_body)
    end
  end

  describe 'when called with a malformed Authorization header' do
    before :each do
      headers = {
        'Authorization' => 'jwt',
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      post '/signup', headers: headers
      # might need a teardown phase to delete any created Users after each test
    end

    it 'responds with 400' do
      expect(response).to have_http_status(400)
    end

    it 'responds with error information in response body' do
      expected_body = JSON.generate({
        errors: [
          {
            status: '400',
            title: 'Malformed Authorization header'
          }
        ]
      })

      expect(response.body).to eq(expected_body)
    end
  end

  describe 'response to a valid request' do
    before :each do
      headers = {
        'Authorization' => 'Bearer valid.jwt.token',
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
