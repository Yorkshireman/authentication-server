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

  it 'cannot be created without a name' do
    expect { User.create(email: 'joebloggs@email.com', password: 'password') }.to change { User.count }.by(0)
  end

  it 'cannot be created without an email' do
    expect { User.create(name: 'Joe', password: 'password') }.to change { User.count }.by(0)
  end

  it 'cannot be created without a password' do
    expect { User.create(email: 'joebloggs@email.com', name: 'Joe') }.to change { User.count }.by(0)
  end

  it 'cannot be created when a user with identical email already exists' do
    User.create(email: 'joebloggs@email.com', name: 'Joe', password: 'password')
    User.create(email: 'joebloggs@email.com', name: 'Mr Foobar', password: 'fizzbuzz')
    expect(User.count).to eq(1)
  end
end
