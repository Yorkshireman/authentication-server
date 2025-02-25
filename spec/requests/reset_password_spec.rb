require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /reset-password', type: :request do
  before :all do
    User.destroy_all
    @user = User.create(email: 'test@test.com', name: 'test', password: 'password')
  end

  describe 'missing email param' do
    it 'returns 400 and does not send an email' do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      post '/reset-password', headers: headers

      expect do
        post '/reset-password', headers: headers
      end.not_to(change { ActionMailer::Base.deliveries.count })

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
    it 'returns 204 and sends an email' do
      headers = {
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      params = JSON.generate({ email: 'test@test.com' })
      post '/reset-password', headers: headers, params: params

      expect do
        post '/reset-password', headers: headers, params: params
      end.to(change { ActionMailer::Base.deliveries.count }.by(1))

      expect(response).to have_http_status(204)
    end
  end
end
# rubocop:enable Metrics/BlockLength
