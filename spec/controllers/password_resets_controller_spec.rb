require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe PasswordResetsController, type: :controller do
  render_views
  let(:user) do
    User.create!(
      email: "test_#{SecureRandom.hex(4)}@test.com",
      name: "test_#{SecureRandom.hex(4)}",
      password: 'password'
    )
  end

  let(:jwt) do
    # Time.now + 1 ensures the token is issued after the user's password_changed_at timestamp
    # and therefore valid
    JWT.encode({ exp: (Time.now + 7200).to_i, issued_at: Time.now + 1, user_id: user.id }, ENV['JWT_SECRET_KEY'],
               'HS256')
  end

  let(:expired_jwt) do
    JWT.encode({ exp: (Time.now - 7300).to_i, issued_at: Time.now + 1, user_id: user.id }, ENV['JWT_SECRET_KEY'],
               'HS256')
  end

  let(:used_jwt) do
    # Time.now - 1 ensures the token is used
    JWT.encode({ exp: (Time.now + 7200).to_i, issued_at: Time.now - 1, user_id: user.id }, ENV['JWT_SECRET_KEY'],
               'HS256')
  end

  describe 'POST #create' do
    it 'returns http success' do
      post :create, params: { email: user.email, user: user }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit
      expect(response).to have_http_status(:success)
    end

    it 'renders the edit template' do
      get :edit, format: :html
      expect(response).to render_template(:edit)
    end

    it 'passes the token from the request params to the edit template' do
      get :edit, params: { token: 'test_token' }
      expect(assigns(:token)).to eq('test_token')
    end
  end

  describe 'GET #update' do
    it 'returns http success' do
      patch :update, params: { token: jwt, password: 'new_password', password_confirmation: 'new_password' }
      expect(response).to have_http_status(:success)
    end

    describe 'when token has already been used' do
      before :each do
        patch :update, params: { token: used_jwt, password: 'new_password', password_confirmation: 'new_password' }
      end

      it 'returns a 422 status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an appropriate error message' do
        expect(JSON.parse(response.body)['errors'][0]).to eq(
          # rubocop:disable Layout/LineLength
          'This password reset link has already been used. If you still need to reset your password, please request a new reset link.'
          # rubocop:enable Layout/LineLength
        )
      end

      it 'does not update the user\'s password' do
        expect(user.password).to eq('password')
      end
    end

    describe 'when token has expired' do
      before :each do
        patch :update, params: { token: expired_jwt, password: 'new_password', password_confirmation: 'new_password' }
      end

      it 'returns a 422 status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an appropriate error message' do
        expect(JSON.parse(response.body)['errors'][0]).to eq(
          # rubocop:disable Layout/LineLength
          'This password reset link has expired. If you still need to reset your password, please request a new reset link.'
          # rubocop:enable Layout/LineLength
        )
      end

      it 'does not update the user\'s password' do
        expect(user.password).to eq('password')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
