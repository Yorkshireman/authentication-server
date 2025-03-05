require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'PATCH /reset-password', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before :all do
    User.destroy_all
    @baseline = Time.now
    travel_to(@baseline) do
      @user = User.create(email: 'test@test.com', name: 'test', password: 'password')
    end
  end

  describe 'when valid request and params' do
    it 'updates user password and returns 204' do
      token = JWT.encode({ exp: (Time.now + 7200).to_i, issued_at: Time.now + 1, user_id: @user.id },
                         ENV['JWT_SECRET_KEY'], 'HS256')
      headers = {
        'CONTENT_TYPE' => 'application/x-www-form-urlencoded; charset=UTF-8'
      }

      patch '/reset-password', headers: headers,
                               params: { token: token, password: 'new_password', password_confirmation: 'new_password' }

      @user.reload
      expect(@user.authenticate('new_password')).to be_truthy
      expect(response).to have_http_status(200)
    end
  end

  describe 'when using the same token twice' do
    it 'returns 422 and error message' do
      travel_to(@baseline + 1) do
        @token = JWT.encode({ exp: (@baseline + 7200).to_i, issued_at: @baseline + 1, user_id: @user.id },
                            ENV['JWT_SECRET_KEY'], 'HS256')
      end

      headers = {
        'CONTENT_TYPE' => 'application/x-www-form-urlencoded; charset=UTF-8'
      }

      travel_to(@baseline + 2.seconds) do
        patch '/reset-password',
              headers: headers,
              params: { token: @token, password: 'new_password', password_confirmation: 'new_password' }
      end

      travel_to(@baseline + 3.seconds) do
        patch '/reset-password', headers: headers,
                                 params: { token: @token, password: 'password', password_confirmation: 'password' }

        expect(response).to have_http_status(422)

        expected_body = JSON.generate({
          errors: [
            # rubocop:disable Layout/LineLength
            'This password reset link has already been used. If you still need to reset your password, please request a new reset link.'
            # rubocop:enable Layout/LineLength
          ]
        })

        expect(response.body).to eq(expected_body)
      end
    end
  end

  describe 'when new password is too short' do
    it 'returns 422 and error message' do
      token = JWT.encode({ exp: (Time.now + 7200).to_i, issued_at: Time.now + 1, user_id: @user.id },
                         ENV['JWT_SECRET_KEY'], 'HS256')
      headers = {
        'CONTENT_TYPE' => 'application/x-www-form-urlencoded; charset=UTF-8'
      }

      patch '/reset-password', headers: headers,
                               params: { token: token, password: 'new', password_confirmation: 'new' }

      expect(response).to have_http_status(422)

      expected_body = JSON.generate({
        errors: [
          'Password is too short (minimum is 8 characters)'
        ]
      })

      expect(response.body).to eq(expected_body)
    end
  end
end
# rubocop:enable Metrics/BlockLength
