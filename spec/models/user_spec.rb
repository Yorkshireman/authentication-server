require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(email: 'joebloggs@email.com', name: 'Joe', password: 'password') }
  before :each do
    User.destroy_all
  end

  it 'has an email' do
    expect(user.email).to eq('joebloggs@email.com')
  end

  it 'has a name' do
    expect(user.name).to eq('Joe')
  end

  it 'has a password' do
    expect(user.password).to eq('password')
  end

  it 'can be created without a name' do
    expect { User.create(email: 'joebloggs@email.com', password: 'password') }.to change { User.count }.by(1)
  end

  it 'cannot be created without an email' do
    expect { User.create(name: 'Joe', password: 'password') }.to change { User.count }.by(0)
  end

  it 'cannot be created without a password' do
    expect { User.create(email: 'joebloggs@email.com', name: 'Joe') }.to change { User.count }.by(0)
  end

  it 'cannot be created when a pre-existing instance has the same name' do
    user
    expect { User.create(email: 'legit@email.com', name: 'Joe', password: 'password') }.to change { User.count }.by(0)
  end

  it 'throws error when attempting to be created, using `create!`, with the same name as a pre-existing User' do
    user
    expect { User.create!(email: 'legit@email.com', name: 'Joe', password: 'password') }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
