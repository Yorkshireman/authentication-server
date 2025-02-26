class User < ApplicationRecord
  before_validation :set_initial_password_changed_at, on: :create
  before_update :update_password_changed_at, if: :will_save_change_to_password_digest?
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :name, uniqueness: true, allow_blank: true
  validates :password_changed_at, presence: true
  validates :password, length: { minimum: ENV['MIN_PASSWORD_LENGTH'].to_i, maximum: ENV['MAX_PASSWORD_LENGTH'].to_i },
                       allow_nil: true

  private

  def set_initial_password_changed_at
    self.password_changed_at = Time.current
  end

  def update_password_changed_at
    self.password_changed_at = Time.current
  end
end
