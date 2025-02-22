class PasswordResetMailer < ApplicationMailer
  def password_reset_email
    @url = "#{ENV['PASSWORD_RESET_URL']}?token=#{params[:token]}"
    mail(to: ENV['TEST_EMAIL_ADDRESS'] || params[:email], subject: 'Password Reset')
  end
end
