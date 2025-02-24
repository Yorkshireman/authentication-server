require 'rails_helper'

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
    JWT.encode({ exp: (Time.now + 7200).to_i, issued_at: Time.now, user_id: user.id }, ENV['JWT_SECRET_KEY'], 'HS256')
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
  end
end
