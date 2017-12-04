Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  get 'login', to: 'sessions#new'

  get 'groceries', to: 'groceries#show'

  resources :users, only: [:edit, :update]

  namespace :api, defaults: {format: :json} do
    resources :stores, only: [:create, :update, :destroy] do
      resources :items, only: [:index, :create]
    end
    resources :items, only: [:update, :destroy]
    resources :text_messages, only: [:create]
  end

  namespace :admin do
    resources :users
    resources :items
    resources :requests, only: [:index, :show]
    resources :stores

    root to: "users#index"
  end

  get 'google83c07e1014ea4a70', to: ->(env) {
    [200, {}, ['google-site-verification: google83c07e1014ea4a70.html']]
  }
end
