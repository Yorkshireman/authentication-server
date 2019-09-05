Rails.application.routes.draw do
  post '/signup', to: 'users#signup'
end
