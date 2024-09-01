require 'jwt'
require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /signup', type: :request do
  describe 'when invalid params' do
    let(:user) { User.first }
    describe 'missing parameter' do
      [
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

        it 'user is not created' do
          expect(User.count).to eq(0)
        end
      end
    end
  end

  describe 'when request is valid' do
    let(:user) { User.first }
    include ActiveSupport::Testing::TimeHelpers
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

      freeze_time do
        @time_now = Time.now
        post '/signup', headers: headers, params: params
      end
    end

    describe 'user' do
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
      it 'has correct MIME type' do
        expect(response.media_type).to eq('application/vnd.api+json')
      end

      it 'has 201 status code' do
        expect(response).to have_http_status(201)
      end

      describe 'token' do
        it 'is a String' do
          expect(JSON.parse(response.body)['data']['token']).to be_a(String)
        end

        it 'contains correct information' do
          expected_decoded_token = [{ 'exp' => (@time_now + 1800).to_i, 'user_id' => user.id }, { 'alg' => 'HS256' }]
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

  describe 'when signing up with an empty name when a previous user signed up with an empty name' do
    include ActiveSupport::Testing::TimeHelpers
    before :all do
      # thought there wouldn't be a need for this. Why doesn't the test db reset after each run of the suite?
      User.destroy_all
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      params = JSON.generate({
        user: {
          email: 'testuser@email.com',
          password: 'password'
        }
      })

      freeze_time do
        @time_now = Time.now
        post '/signup', headers: headers, params: params
      end

      freeze_time do
        @time_now = Time.now
        params = JSON.generate({
          user: {
            email: 'testuser2@email.com',
            password: 'password'
          }
        })
        post '/signup', headers: headers, params: params
      end
    end

    let(:user) { User.second }
    describe 'user' do
      it 'has correct email' do
        expect(user.email).to eq('testuser2@email.com')
      end

      it 'has no name' do
        expect(user.name).to be nil
      end

      it 'has a password' do
        expect(user.password_digest).to be_truthy
      end
    end

    describe 'response' do
      it 'has correct MIME type' do
        expect(response.media_type).to eq('application/vnd.api+json')
      end

      it 'has 201 status code' do
        expect(response).to have_http_status(201)
      end

      describe 'token' do
        it 'is a String' do
          expect(JSON.parse(response.body)['data']['token']).to be_a(String)
        end

        it 'contains correct information' do
          expected_decoded_token = [{ 'exp' => (@time_now + 1800).to_i, 'user_id' => user.id }, { 'alg' => 'HS256' }]
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

  describe 'when attempting to create a user with a duplicate email' do
    before :all do
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
      post '/signup', headers: headers, params: JSON.generate({
        user: {
          email: 'testuser@email.com',
          name: 'Mr Foobar',
          password: 'fizzbuzz'
        }
      })
    end

    it 'it cannot be created' do
      expect(User.count).to eq(1)
    end

    describe 'response' do
      it 'response is 403' do
        expect(response).to have_http_status(403)
      end

      it 'has correct MIME type' do
        expect(response.media_type).to eq('application/vnd.api+json')
      end

      it 'response body has error' do
        expected_body = JSON.generate({
          errors: [
            { title: 'Validation failed: Email has already been taken' }
          ]
        })

        expect(response.body).to eq(expected_body)
      end
    end
  end

  describe 'when attempting to create a user with a duplicate name' do
    before :all do
      User.destroy_all
      User.create!(email: 'joebloggs@email.com', name: 'Joe', password: 'password')
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      post '/signup', headers: headers, params: JSON.generate({
        user: {
          email: 'legit@email.com',
          name: 'Joe',
          password: 'foobar'
        }
      })
    end

    it 'it cannot be created' do
      expect(User.count).to eq(1)
    end

    describe 'response' do
      it 'response is 403' do
        expect(response).to have_http_status(403)
      end

      it 'has correct MIME type' do
        expect(response.media_type).to eq('application/vnd.api+json')
      end

      it 'response body has error' do
        expected_body = JSON.generate({
          errors: [
            { title: 'Validation failed: Name has already been taken' }
          ]
        })

        expect(response.body).to eq(expected_body)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
