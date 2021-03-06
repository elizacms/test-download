require 'sidekiq/web'

  Rails.application.routes.draw do
  domain = {
    production: ENV['NLU_CMS_URI'],
    development: 'http://localhost:3000',
    test: ENV['NLU_CMS_URI']
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
  resources :field_data_types, only: [:index, :show]

  get '/entities/:id/download-entity-data',
    to: 'field_data_types#download',
    as: :download_entity_data

  post '/entities/:id/upload',
    to: 'field_data_types#upload',
    as: :upload_entity_data

  get '/releases',
    to: 'releases#index',
    as: :releases

  post '/releases',
    to: 'releases#create'

  get '/releases/new',
    to: 'releases#new',
    as: :new_release

  get '/releases/:id/review',
    to: 'releases#review',
    as: :review_release

  post '/releases/submit_to_training',
    to: 'releases#submit_to_training',
    as: :submit_to_training

  match '/releases/:id/accept_or_reject',
    to: 'releases#accept_or_reject',
    as: :accept_or_reject,
    via: [ 'GET','POST']

  post '/releases/approval_or_rejection',
    to: 'releases#approval_or_rejection',
    as: :approval_or_rejection

  match '/ajax-developers',
    to: 'roles#ajax_set_or_unset_developers',
    as: :ajax_set_or_unset_developers,
    via: ['POST', 'PATCH']

  post '/set-all-developer-roles',
    to: 'roles#set_all_developer_roles',
    as: :set_all_developer_roles

  match '/ajax-owners',
    to: 'roles#ajax_set_or_unset_owners',
    as: :ajax_set_or_unset_owners,
    via: ['POST', 'PATCH']

  post '/set-all-owner-roles',
    to: 'roles#set_all_owner_roles',
    as: :set_all_owner_roles

  get '/owners',
    to: 'users#owners',
    as: :owners

  get '/developers',
    to: 'users#developers',
    as: :users_developers

  get '/developers/:skill_id',
    to: 'users#developers',
    as: :developers

  get '/developers/:skill_id/invite',
    to: 'users#invite_developer',
    as: :invite_dev

  get '/faqs',
    to: 'faqs#index'

  get '/single-word-rules',
    to: 'single_word_rule#landing'

  post '/single-word-rules/clear-changes',
    to: 'single_word_rule#clear_changes',
    as: :clear_single_word_rule_changes

  get '/stop-words',
    to: 'stop_word#landing'

  get '/stop-words',
    to: 'stop_word#index'

  post '/stop-words/clear-changes',
    to: 'stop_word#clear_changes',
    as: :clear_stop_word_changes

  resources :skills do
    resources :intents

    put '/intents/:id/mturk_response',
      to: 'intents#submit_mturk_response'
  end

  post '/skills/:skill_id/intents/:id/clear-changes',
    to: 'intents#clear_changes',
    as: :clear_intent_changes

  post '/field_data_type/:id/clear-changes',
    to: 'field_data_types#clear_changes',
    as: :clear_field_data_type_changes

  resources :fields

  scope :api do
    get '/webhooks',
      to: 'api#get_webhook'

    post '/intents-list',
      to: 'api#intents_list'

    post '/wrapper-query',
      to: 'api#wrapper_query'

    post '/nlu-query',
      to: 'api#nlu_query'

    post '/skill',
      to: 'api#skill'

    post '/process_intent_upload',
      to: 'api#process_intent_upload'

    post '/process_dialog_upload',
      to: 'api#process_dialog_upload'

    get '/field-data-types',
      to: 'api#field_data_types'

    get '/intents',
      to: 'api#get_intents'

    get '/single_word_rules',
      to: 'single_word_rule#index'

    post '/single_word_rules',
      to: 'single_word_rule#create'

    put '/single_word_rules',
      to: 'single_word_rule#update'

    get '/single_word_rules/check_lock',
      to: 'single_word_rule#check_lock'

    get '/stop_words',
      to: 'stop_word#index'

    post '/stop_words',
      to: 'stop_word#create'

    put '/stop_words',
      to: 'stop_word#update'

    get '/stop_words/check_lock',
      to: 'stop_word#check_lock'

    scope module:'faq' do
      get '/articles/search',
        to: 'api#search'

      get '/articles',
        to: 'api#get_articles'

      post '/articles',
        to: 'api#post_articles'

      put '/articles/:kbid',
        to: 'api#put_articles'

      delete 'articles/:kbid',
        to: 'api#delete_articles'
    end
  end

  post '/process_training_data_upload',
    to: 'training_data#upload'

  get '/intent/:intent_id/download-training-data',
    to: 'training_data#download',
    as: :download_training_data

  post '/dialogue_api/response',
    to: 'dialogs#create',
    as: :submit_dialogs

  put '/dialogue_api/response',
    to: 'dialogs#update',
    as: :update_dialogs

  get '/dialogue_api/all_scenarios',
    to: 'dialogs#index',
    as: :get_dialogs

  delete '/dialogue_api/response/:id',
    to: 'dialogs#delete_response',
    as: :delete_response

  delete '/dialogue_api/response',
    to: 'dialogs#delete',
    as: :delete_dialogs

  get '/skills/:skill_id/intents/:id/fields',
    to: 'intents#fields',
    as: :fields_page

  get '/file_lock',
    to: 'intents#api_file_lock',
    as: :api_file_lock

  get '/skills/:skill_id/intents/:id/dialogs',
    to: 'intents#dialogs',
    as: :dialogs_page

  get '/dialogs-upload',
    to: 'pages#dialogs_upload',
    as: :dialogs_upload

  get '/test-queries',
    to: 'pages#test_queries',
    as: :test_queries

  mount Sidekiq::Web => '/sidekiq'
end
