Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :items
    resources :requests
    resources :stores
    resources :templates

    root to: "users#index"
  end

  root to: 'home#index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  get 'groceries', to: 'grocery_lists#show'
  get 'login', to: 'sessions#new'
  resources :templates, only: [:index, :new, :create, :show]
  namespace :api, defaults: {format: :json} do
    resources :stores, only: [:create, :index] do
      resources :items, only: [:index, :create]
    end
    resources :items, only: [:update]
    resources :templates, only: [:update]
  end
end
