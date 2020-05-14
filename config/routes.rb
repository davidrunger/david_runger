# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'
  get 'upgrade_browser', to: 'home#upgrade_browser'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_scope :user do
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
  get 'logs', to: 'logs#index'
  namespace :logs do
    resources :uploads, only: %i[index create]
  end
  get 'logs/:slug', to: 'logs#index', as: :log # routing to specific log will be done by Vue Router

  resources :users, only: %i[edit update] do
    get 'logs/:slug', to: 'logs#index', as: :shared_log
  end

  namespace :api, defaults: {format: :json} do
    resources :items, only: %i[update destroy]
    resources :log_entries, only: %i[create destroy index update]
    resources :log_shares, only: %i[create destroy]
    resources :logs, only: %i[create destroy update]
    resources :stores, only: %i[create update destroy] do
      resources :items, only: %i[create]
    end
    resources :text_messages, only: %i[create]
  end

  namespace :admin do
    resources :users
    resources :items
    resources :requests, only: %i[index show]
    resources :stores

    root to: 'users#index'
  end

  authenticate :user, ->(user) { user.admin? } do
    mount PgHero::Engine, at: 'pghero'
    mount Sidekiq::Web => '/sidekiq'
  end

  # Google periodically re-verifies this route, so we need to leave it here indefinitely
  # rubocop:disable Layout/MultilineMethodArgumentLineBreaks
  get 'google83c07e1014ea4a70', to: ->(_env) {
    [200, {}, ['google-site-verification: google83c07e1014ea4a70.html']]
  }
  # rubocop:enable Layout/MultilineMethodArgumentLineBreaks
end
