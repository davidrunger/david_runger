Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  get 'login', to: 'sessions#new'

  get 'groceries', to: 'groceries#show'

  get 'logs', to: 'logs#index'
  get 'logs/:slug', to: 'logs#index' # routing to specific log will be done by Vue Router

  resources :users, only: %i[edit update]

  namespace :api, defaults: {format: :json} do
    resources :items, only: %i[update destroy]
    resources :log_entries, only: %i[create destroy index]
    resources :logs, only: %i[create]
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
  end

  # Google periodically re-verifies this route, so we need to leave it here indefinitely
  get 'google83c07e1014ea4a70', to: ->(_env) {
    [200, {}, ['google-site-verification: google83c07e1014ea4a70.html']]
  }
end
