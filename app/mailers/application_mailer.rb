class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{ENV['MY_WORDLIST_DOMAIN']}"
  layout 'mailer'
end
