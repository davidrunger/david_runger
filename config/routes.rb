Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  get 'grocery_list', to: 'grocery_lists#show'
  resources :templates, only: [:index, :new, :create, :show]
  namespace :api, defaults: {format: :json} do
    resources :stores, only: [:create, :index] do
      resources :items, only: [:index, :create]
    end
    resources :items, only: [:update]
    resources :templates, only: [:update]
  end
end
