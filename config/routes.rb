Rails.application.routes.draw do
  get '/favicon.ico', to: ->(_env) { [204, {}, []] }
  get '/reset-password', to: 'password_resets#edit'
  get '/reset-password/success', to: 'password_resets#success'

  namespace :api do
    post '/reset-password', to: 'password_resets#create'
    patch '/reset-password', to: 'password_resets#update', as: :update_password
    post '/signin', to: 'users#signin'
    post '/signup', to: 'users#signup'
  end
end
