require './app/helpers/token_helper'

desc 'Generate an auth token with a given user_id'
task :generate_token, [:user_id] do |_, args|
  unless args[:user_id]
    puts 'Error: You must provide a user_id.'
    exit
  end

  include TokenHelper
  token = generate_token({ user_id: args[:user_id] })
  puts token
end
