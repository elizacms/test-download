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

    put '/intents/:id/mturk_response', to: 'intents#submit_mturk_response'
  end

  resources :fields

  scope :api do
    get '/webhooks',
      to: 'api#get_webhook'
  end

  get '/types/field-data-types',
    to: 'types#field_data_types',
    as: :field_data_types

  post '/dialogue_api/response',
    to: 'dialogs#create',
    as: :submit_dialogs

  put '/dialogue_api/response',
    to: 'dialogs#update',
    as: :update_dialogs

  get '/dialogue_api/all_scenarios',
    to: 'dialogs#index',
    as: :get_dialogs

  get '/dialogue_api/csv',
    to: 'dialogs#csv'

  delete '/dialogue_api/response',
    to: 'dialogs#delete',
    as: :delete_dialogs

  get '/skills/:skill_id/intents/:id/fields',
    to: 'intents#fields',
    as: :fields_page

  get '/skills/:skill_id/intents/:id/dialogs',
    to: 'intents#dialogs',
    as: :dialogs_page

  # Below are for the Test Queries
  get '/test-queries',
    to: 'pages#test_queries',
    as: :test_queries

  post '/wrapper-query',
    to: 'api#wrapper_query'

  post '/nlu-query',
    to: 'api#nlu_query'

  post '/skills/news-skill-format',
    to: 'api#news_skill_format'

  post '/skills/news-skill-retrieve',
    to: 'api#news_skill_retrieve'

  post '/skills/music-skill-format',
    to: 'api#music_skill_format'

  post '/skills/music-skill-retrieve',
    to: 'api#music_skill_retrieve'
end
