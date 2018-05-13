Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  get 'login', to: 'sessions#new'

  get 'groceries', to: 'groceries#show'

  get 'log', to: 'logs#index'

  resources :users, only: %i[edit update]

  namespace :api, defaults: {format: :json} do
    resources :stores, only: %i[create update destroy] do
      resources :items, only: %i[create]
    end
    resources :items, only: %i[update destroy]
    resources :text_messages, only: %i[create]
  end

  namespace :admin do
    resources :users
    resources :items
    resources :requests, only: %i[index show]
    resources :stores

    root to: 'users#index'
  end

  authenticate :user, -> (user) { user.admin? } do
    mount PgHero::Engine, at: 'pghero'
  end

  # Google periodically re-verifies this route, so we need to leave it here indefinitely
  get 'google83c07e1014ea4a70', to: ->(env) {
    [200, {}, ['google-site-verification: google83c07e1014ea4a70.html']]
  }
end
