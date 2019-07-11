Rails.application.routes.draw do
  get '/', to: 'users#index'
  post 'auth/login', to: 'users#login'
  post 'auth/register', to: 'users#register'
end
