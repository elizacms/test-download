Rails.application.routes.draw do
  root to:'pages#index'

  get '/login/success',
    to: 'pages#login_success'

  post '/logout',
    to: 'pages#current_user_session_destroy'

  resources :users
  resources :skills do
    resources :intents
  end

  get '/skills/:skill_id/intents/:id/fields_and_dialogs',
    to: 'intents#fields_and_dialogs',
    as: 'fields_and_dialogs'
end
