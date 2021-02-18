# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'
  get 'upgrade_browser', to: 'home#upgrade_browser'

  devise_for :users
  devise_scope :user do
    get '/users/auth/google_oauth2/callback' => 'users/omniauth_callbacks#google_oauth2'
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  get 'login', to: 'sessions#new'
  # https://stackoverflow.com/a/46218826/4009384
  Rails.application.routes.named_routes.tap do |named_routes|
    named_routes['new_session'] = named_routes['login']
    named_routes['new_user_session'] = named_routes['login']
  end

  get 'groceries', to: 'groceries#index'
  get 'workout', to: 'workouts#index'
  get 'workouts', to: redirect('workout')
  get 'logs', to: 'logs#index'
  namespace :logs do
    resources :uploads, only: %i[new create]
  end
  get 'logs/:slug', to: 'logs#index', as: :log # routing to specific log will be done by Vue Router

  resources :users, only: %i[edit update] do
    get 'logs/:slug', to: 'logs#index', as: :shared_log
  end

  resources :auth_tokens, only: %i[create destroy update]

  resources :quizzes, only: %i[index new create show update] do
    member do
      get :respondents
      get :leaderboard
      get :progress
    end
    resources :quiz_participations, only: %i[create]
    resources :question_uploads, only: %i[new create]
    resources :quiz_question_answer_selections, only: %i[create update]
  end
  resources :quiz_questions, only: %i[update]

  namespace :api, defaults: { format: :json } do
    resources :items, only: %i[update destroy]
    namespace :items do
      resources :bulk_update, only: %i[create]
    end
    resources :log_entries, only: %i[create destroy index update]
    resources :log_shares, only: %i[create destroy]
    resources :logs, only: %i[create destroy update]
    resources :stores, only: %i[create update destroy] do
      resources :items, only: %i[create]
    end
    resources :text_messages, only: %i[create]
    resources :users, only: %i[update]
    resources :workouts, only: %i[create update]
  end

  devise_for :admin_users
  get '/admin/login', to: 'admin/sessions#new'
  devise_scope :admin_user do
    get '/admin_users/auth/google_oauth2/callback' => 'admin/omniauth_callbacks#google_oauth2'
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_admin_user_session
  end
  ActiveAdmin.routes(self)

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
    mount Flipper::UI.app(Flipper) => '/flipper'
  end

  # Google periodically re-verifies this route, so we need to leave it here indefinitely
  get(
    'google83c07e1014ea4a70',
    to: ->(_env) { [200, {}, ['google-site-verification: google83c07e1014ea4a70.html']] },
  )

  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unacceptable', via: :all
  get '/500', to: 'errors#internal_error', via: :all
end
