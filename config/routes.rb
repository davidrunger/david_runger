Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  resources :templates, only: [:index, :new, :create, :show]
  namespace :api, constraints: {format: :json} do
    resources :templates, only: [:update]
  end
end
