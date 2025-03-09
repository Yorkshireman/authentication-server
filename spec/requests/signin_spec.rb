require 'jwt'
require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /api/signin', type: :request do
  before :all do
    User.destroy_all
    @user = User.create(email: 'test@test.com', name: 'test', password: 'password')
  end

  describe 'when invalid params' do
    describe 'missing parameter' do
      [
        { email: 'test@test.com' },
        { password: 'password' }
      ].each do |user_params|
        before :all do
          headers = {
            'CONTENT_TYPE' => 'application/vnd.api+json'
          }

          params = JSON.generate({
            user: user_params
          })

          post '/api/signin', headers: headers, params: params
        end

        it 'response is 400' do
          expect(response).to have_http_status(400)
        end

        it 'has correct MIME type' do
          expect(response.media_type).to eq('application/vnd.api+json')
        end

        it 'response body has error' do
          expected_body = JSON.generate({
            errors: [
              { title: 'Missing parameter(s).' }
            ]
          })

          expect(response.body).to eq(expected_body)
        end
      end
    end

    describe 'incorrect password' do
      before :all do
        headers = {
          'CONTENT_TYPE' => 'application/vnd.api+json'
        }

        params = JSON.generate({
          user: {
            email: 'test@test.com',
            password: 'foobar'
          }
        })

        post '/api/signin', headers: headers, params: params
      end

      it 'response is 401' do
        expect(response).to have_http_status(401)
      end

      it 'response body has error' do
        expected_body = JSON.generate({
          errors: [
            { title: 'Incorrect email/password.' }
          ]
        })

        expect(response.body).to eq(expected_body)
      end
    end

    describe 'non-existent email' do
      before :all do
        headers = {
          'CONTENT_TYPE' => 'application/vnd.api+json'
        }

        params = JSON.generate({
          user: {
            email: 'foo@bar.com',
            password: 'password'
          }
        })

        post '/api/signin', headers: headers, params: params
      end

      it 'response is 401' do
        expect(response).to have_http_status(401)
      end

      it 'response body has error' do
        expected_body = JSON.generate({
          errors: [
            { title: 'Incorrect email/password.' }
          ]
        })

        expect(response.body).to eq(expected_body)
      end
    end
  end

  describe 'when request is valid' do
    include ActiveSupport::Testing::TimeHelpers
    before :all do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      params = JSON.generate({
        user: {
          email: 'test@test.com',
          password: 'password'
        }
      })

      freeze_time do
        @time_now = Time.now
        post '/api/signin', headers: headers, params: params
      end
    end

    describe 'response' do
      it 'has correct MIME type' do
        expect(response.media_type).to eq('application/vnd.api+json')
      end

      it 'has 200 status code' do
        expect(response).to have_http_status(200)
      end

      describe 'token' do
        it 'is a String' do
          expect(JSON.parse(response.body)['data']['token']).to be_a(String)
        end

        it 'contains correct information' do
          expected_decoded_token = [{ 'exp' => (@time_now + 1800).to_i, 'user_id' => @user.id }, { 'alg' => 'HS256' }]
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
