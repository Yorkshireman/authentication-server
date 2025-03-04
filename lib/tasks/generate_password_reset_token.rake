desc 'Generate a password reset token with a given user_id'
task :generate_password_reset_token, [:user_id] do |_, args|
  unless args[:user_id]
    puts 'Error: You must provide a user_id.'
    exit
  end

  include TokenHelper
  token = generate_token({ exp: (Time.now + 7200).to_i, issued_at: Time.now.to_f, user_id: args[:user_id] })
  puts token
end
