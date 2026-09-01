require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'
  get 'upgrade_browser', to: 'home#upgrade_browser'

  devise_for :users
  devise_scope :user do
    get '/users/auth/google_oauth2/callback' => 'users/omniauth_callbacks#google_oauth2'
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  get 'login', to: 'sessions#new', as: :new_user_session
  resource :my_account, controller: :my_account, only: %i[destroy edit show update]
  resources :authenticated_sessions, only: [] do
    member do
      patch :revoke
    end
  end

  get 'blog', to: 'blog#index'
  get 'blog/:slug', to: 'blog#show'
  get 'blog/*path' => 'blog#assets'

  get 'emoji-picker', to: 'emoji_picker#index'

  get 'groceries', to: 'groceries#index'
  get 'workouts', to: 'workouts#index'
  get 'workout', to: redirect('workouts')
  resources :logs, only: %i[index], param: :slug do
    member do
      get :download
    end
  end
  namespace :logs do
    resources :uploads, only: %i[new create]
  end
  get 'logs/:slug', to: 'logs#index', as: :log # routing to specific log will be done by Vue Router
  get 'logs/:slug/log_entries/create', to: 'log_entries#create', as: :log_log_entries_create

  resources :users, only: [] do
    get 'logs/:slug', to: 'logs#index', as: :shared_log
  end

  resources :check_ins, only: %i[create index show]
  %w[check_in check-ins check-in checkins checkin].each do |path|
    get path, to: redirect('check_ins')
  end
  resources :proposals, only: %i[create], param: :public_id do
    member do
      get :confirm
      post :accept
      post :cancel
    end
  end
  resource :marriage, only: %i[destroy new show]
  resources :emotional_needs, only: %i[create destroy edit update] do
    member do
      get :history
    end
  end

  resources :auth_tokens, only: %i[create destroy update]

  resources :quizzes, only: %i[index show]

  resources :ci_step_results, only: %i[index]

  namespace :api, defaults: { format: :json } do
    resources :check_ins, only: [] do
      resources :check_in_submissions, only: %i[create]
    end
    namespace :ci_step_results do
      resources :bulk_creations, only: %i[create]
    end
    resources :comments, only: %i[create destroy index update]
    resources :events, only: %i[create]
    resources :need_satisfaction_ratings, only: %i[update]
    resources :csp_reports, only: %i[create]
    resources :items, only: %i[update destroy]
    resources :deleted_item_restorations, only: %i[create]
    resources :item_merges, only: %i[create]
    namespace :items do
      resources :bulk_updates, only: %i[create]
    end
    resource :json_preferences, only: %i[update]
    resources :log_entries, only: %i[create destroy index update]
    resources :log_shares, only: %i[create destroy]
    resources :logs, only: %i[create destroy update] do
      post :rotate_email_submission_token, on: :member
    end
    resource :my_account, controller: :my_account, only: %i[update]
    resources :stores, only: %i[index create update destroy] do
      resources :items, only: %i[create]
    end
    resources :webhook_email_forwards, only: %i[create]
    resources :workouts, only: %i[create update]
  end

  devise_for :admin_users
  devise_scope :admin_user do
    get '/admin_users/auth/google_oauth2/callback' => 'admin/omniauth_callbacks#google_oauth2'
    delete '/admin_users/sign_out', to: 'devise/sessions#destroy', as: :destroy_admin_user_session
  end
  get '/admin/login', to: 'admin/sessions#new', as: :new_admin_user_session
  ActiveAdmin.routes(self)

  authenticate :admin_user do
    get 'vue-playground', to: 'vue_playground#index'
    mount Blazer::Engine, at: 'blazer'
    mount Flipper::UI.app(Flipper), at: 'flipper'
    mount PgHero::Engine, at: 'pghero'
    mount Sidekiq::Web, at: 'sidekiq'
  end

  get 'models', to: 'model_graph#index'
  get 'sha', to: ->(_env) { plain_text_response(ENV.fetch('GIT_REV')) }
  get 'up', to: 'health_checks#index'
  post(
    '/rails/action_mailbox/mailgun/inbound_emails/mime',
    to: 'mailgun_inbound_emails#create',
  )

  def plain_text_response(text)
    [200, { 'Content-Disposition' => 'inline', 'Content-Type' => 'text/plain' }, [text]]
  end

  # Google periodically re-verifies this route, so we need to leave it here indefinitely
  get(
    'google83c07e1014ea4a70',
    to: ->(_env) { plain_text_response('google-site-verification: google83c07e1014ea4a70.html') },
  )

  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unacceptable', via: :all
  get '/500', to: 'errors#internal_error', via: :all
end
