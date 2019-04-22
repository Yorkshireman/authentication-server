Rails.application.routes.draw do
  post 'auth/register', to: 'users#register'
end
