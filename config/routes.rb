Rails.application.routes.draw do
  post '/signin', to: 'users#signin'
  post '/signup', to: 'users#signup'
end
