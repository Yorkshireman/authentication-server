namespace :server do
  desc "Delete all users, seed db, start server"
  task start: :environment do
    sh %{ rails db:seed }
    trap('SIGINT') { exit }
    sh %{ rails s -p 3100 }
  end
end
