Rails.application.routes.draw do
  get '/favicon.ico', to: ->(_env) { [204, {}, []] }
  post '/reset-password', to: 'password_resets#create'
  get '/reset-password', to: 'password_resets#edit'
  patch '/reset-password', to: 'password_resets#update', as: :update_password
  get '/reset-password/success', to: 'password_resets#success'
  post '/signin', to: 'users#signin'
  post '/signup', to: 'users#signup'
end
