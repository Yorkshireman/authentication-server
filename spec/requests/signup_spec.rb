require 'jwt'
require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /signup', type: :request do
  # write test for what happens with application/json Accept header

  describe 'when invalid params' do
    let(:user) { User.first }
    describe 'missing parameter' do
      [
        {
          email: 'testuser@email.com',
          password: 'password'
        },
        {
          email: 'testuser@email.com',
          name: 'JoeBloggs'
        },
        {
          name: 'JoeBloggs',
          password: 'password'
        }
      ].each do |user_params|
        before :all do
          User.destroy_all
          headers = {
            'CONTENT_TYPE' => 'application/vnd.api+json'
          }

          params = JSON.generate({
            user: user_params
          })

          post '/signup', headers: headers, params: params
        end

        it 'response is 400' do
          expect(response).to have_http_status(400)
        end

        it 'user is not created' do
          expect(User.count).to eq(0)
        end
      end
    end
  end

  describe 'when request is valid' do
    let(:user) { User.first }
    before :all do
      # thought there wouldn't be a need for this. Why doesn't the test db reset after each run of the suite?
      User.destroy_all
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      params = JSON.generate({
        user: {
          email: 'testuser@email.com',
          name: 'JoeBloggs',
          password: 'password'
        }
      })

      post '/signup', headers: headers, params: params
    end

    it 'creates a user' do
      expect(User.count).to eq(1)
    end

    describe 'created user' do
      it 'has correct email' do
        expect(user.email).to eq('testuser@email.com')
      end

      it 'has correct name' do
        expect(user.name).to eq('JoeBloggs')
      end

      it 'has a password' do
        expect(user.password_digest).to be_truthy
      end
    end

    describe 'response' do
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
          expected_decoded_token = [{ 'user_id' => user.id }, { 'alg' => 'HS256' }]
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
end
# rubocop:enable Metrics/BlockLength
