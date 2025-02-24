require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /reset-password', type: :request do
  before :all do
    User.destroy_all
    @user = User.create(email: 'test@test.com', name: 'test', password: 'password')
  end

  describe 'missing email param' do
    before :all do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      post '/reset-password', headers: headers
    end

    it 'response is 400' do
      expect(response).to have_http_status(400)
    end
  end

  describe 'email not found' do
    before :each do
      ActionMailer::Base.deliveries.clear
    end

    it 'returns 204 No Content and does not send an email' do
      headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
      params = JSON.generate({ email: 'foo@bar.com' })

      expect do
        post '/reset-password', headers: headers, params: params
      end.not_to(change { ActionMailer::Base.deliveries.count })

      expect(response).to have_http_status(204)
    end
  end

  describe 'email is found' do
    before :all do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      params = JSON.generate({ email: 'test@test.com' })
      post '/reset-password', headers: headers, params: params
    end

    it 'response is 204 No Content' do
      expect(response).to have_http_status(204)
    end
  end
end
# rubocop:enable Metrics/BlockLength
