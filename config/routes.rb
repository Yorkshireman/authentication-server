Rails.application.routes.draw do
  post '/reset-password', to: 'password_resets#create'
  get '/reset-password', to: 'password_resets#edit'
  patch '/reset-password', to: 'password_resets#update', as: :update_password
  post '/signin', to: 'users#signin'
  post '/signup', to: 'users#signup'
end
