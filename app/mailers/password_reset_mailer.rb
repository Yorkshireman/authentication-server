class PasswordResetMailer < ApplicationMailer
  default from: 'no-reply@mywordlist.com'

  def password_reset_email
    @user = { email: ENV['TEST_USER_EMAIL_ADDRESS'], name: 'hardcoded-username' }
    @url = ENV['PASSWORD_RESET_URL']
    mail(to: @user[:email], subject: 'Password Reset')
  end
end
