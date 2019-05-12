Rails.application.routes.draw do
  get 'test', to: 'users#test'
  post 'auth/login', to: 'users#login'
  post 'auth/register', to: 'users#register'
end
