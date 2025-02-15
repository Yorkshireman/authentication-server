Rails.application.routes.draw do
  # Route for submitting an email to initiate the reset process
  post '/reset-password', to: 'password_resets#create'
  # Route for displaying the reset form (the email link should point here, often with a token parameter)
  get '/reset-password/edit', to: 'password_resets#edit', as: :edit_password_reset
  # Route for updating the password
  patch '/reset-password', to: 'password_resets#update'
  post '/signin', to: 'users#signin'
  post '/signup', to: 'users#signup'
end
