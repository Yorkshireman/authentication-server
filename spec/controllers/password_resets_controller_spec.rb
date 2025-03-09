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

  describe 'GET #edit' do
    it 'returns 200' do
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
end
