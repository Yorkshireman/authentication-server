class PasswordResetMailerPreview < ActionMailer::Preview
  def password_reset_email
    PasswordResetMailer.with(email: 'example@example.com', token: 'example_token').password_reset_email
  end
end
