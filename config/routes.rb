Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  get 'login', to: 'sessions#new'

  get 'groceries', to: 'groceries#show'

  resources :users, only: %i[edit update]

  namespace :api, defaults: {format: :json} do
    resources :stores, only: %i[create update destroy] do
      resources :items, only: %i[index create]
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
end
