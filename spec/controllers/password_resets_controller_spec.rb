require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  describe 'POST #create' do
    it 'returns http success' do
      post :create, params: { email: 'test@test.com' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #update' do
    it 'returns http success' do
      get :update
      expect(response).to have_http_status(:success)
    end
  end
end
