class User < ApplicationRecord
  has_secure_password
  validates :email, :name, presence: true
end
