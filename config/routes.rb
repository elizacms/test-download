Rails.application.routes.draw do
  root to:'pages#index'

  get '/login/success', to:'pages#login_success'

  resources :users
  resources :skills
end
