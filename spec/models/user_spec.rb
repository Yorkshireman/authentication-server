require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(email: 'joebloggs@email.com', name: 'Joe', password: 'password') }

  it 'has an email' do
    expect(user.email).to eq('joebloggs@email.com')
  end

  it 'has a name' do
    expect(user.name).to eq('Joe')
  end

  it 'has a password' do
    expect(user.password).to eq('password')
  end
end
