Rails.application.routes.draw do
  domain = {
    production: ENV['SKILLS_MANAGER_URI'],
    development: 'http://localhost:3000',
    test: ENV['SKILLS_MANAGER_URI']
  }
  default_url_options host: domain[Rails.env.to_sym] # 'https://developer.aneeda.ai'

  root to:'pages#index'

  get '/login/success',
    to: 'pages#login_success',
    as: :login_success

  post '/logout',
    to: 'pages#current_user_session_destroy',
    as: :logout

  resources :users
  
  resources :skills do
    resources :intents
  end
  
  resources :fields do
    resources :dialogs
  end

  get '/skills/:skill_id/intents/:id/fields',
    to: 'intents#fields',
    as: 'fields_page'
end
