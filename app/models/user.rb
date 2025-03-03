class User < ApplicationRecord
  before_validation :set_initial_password_changed_at, on: :create
  before_update :update_password_changed_at, if: :will_save_change_to_password_digest?
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :name, uniqueness: true, allow_blank: true
  validates :password_changed_at, presence: true
  validates :password, length: { minimum: ENV['MIN_PASSWORD_LENGTH'].to_i, maximum: ENV['MAX_PASSWORD_LENGTH'].to_i },
                       allow_nil: true

  validate :password_must_be_different, if: :will_save_change_to_password_digest?

  private

  def password_must_be_different
    return if password_digest_was.nil? || password_digest_was.empty?
    return unless BCrypt::Password.new(password_digest_was) == password

    errors.add(:password, 'must be different from your current password.')
  end

  def set_initial_password_changed_at
    self.password_changed_at = Time.current
  end

  def update_password_changed_at
    self.password_changed_at = Time.current
  end
end
