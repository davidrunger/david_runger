Rails.application.routes.draw do
  root to: 'home#index'
  get 'new_home', to: 'home#new_home'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  get 'login', to: 'sessions#new'

  get 'groceries', to: 'grocery_lists#show'

  resources :templates, only: [:index, :new, :create, :show]

  namespace :api, defaults: {format: :json} do
    resources :stores, only: [:create, :destroy] do
      resources :items, only: [:index, :create]
    end
    resources :items, only: [:update, :destroy]
    resources :templates, only: [:update]
  end

  namespace :admin do
    resources :users
    resources :items
    resources :requests, only: [:index, :show]
    resources :stores
    resources :templates

    root to: "users#index"
  end
end
