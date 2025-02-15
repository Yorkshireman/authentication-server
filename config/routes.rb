Rails.application.routes.draw do
  get 'password_resets/edit'
  get 'password_resets/update'
  post '/signin', to: 'users#signin'
  post '/signup', to: 'users#signup'
end
