require 'rails_helper'
# rubocop:disable Metrics/BlockLength
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

  describe 'password validation' do
    it 'cannot be created with a password that is too short' do
      expect do
        User.create(email: "foo#{SecureRandom.hex(2)}@bar.com", password: 'passwo7')
      end
        .to change { User.count }.by(0)
    end

    it 'raises an error when the new password is the same as the current password' do
      user.password = 'password'
      user.password_confirmation = 'password'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('must be different from your current password.')
    end

    it 'is valid when the new password is different from the current password' do
      user.password = 'new_password'
      user.password_confirmation = 'new_password'
      expect(user).to be_valid
    end
  end

  it 'cannot be created with a password that is too long' do
    expect do
      User.create(email: "foo#{SecureRandom.hex(2)}@bar.com", password: SecureRandom.hex(33))
    end.to change { User.count }.by(0)
  end

  it 'has a password_changed_at' do
    expect(user.password_changed_at).to be_a(Time)
  end

  it 'can be created without a name' do
    expect { User.create(email: 'joebloggs@email.com', password: 'password') }.to change { User.count }.by(1)
  end

  it 'can be created without a name when another user also has no name' do
    User.create(email: 'joebloggs@email.com', password: 'password')
    expect { User.create(email: 'anotheruser@email.com', password: 'password') }.to change { User.count }.by(1)
  end

  it 'can be created with empty string as a name when another user also has the same' do
    User.create(email: 'joebloggs@email.com', name: '', password: 'password')
    expect { User.create(email: 'anotheruser@email.com', name: '', password: 'password') }.to change {
                                                                                                User.count
                                                                                              }.by(1)
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
    expect { User.create!(email: 'legit@email.com', name: 'Joe', password: 'password') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
# rubocop:enable Metrics/BlockLength
