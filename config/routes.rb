Rails.application.routes.draw do
  root "static_pages#home"
  get "/about", to: "static_pages#about"

  # Devise routes for user authentication
  devise_for :users

  # Define user_root_path
  devise_scope :user do
    get 'profile/:id', to: 'profiles#show', as: :user_root
  end

  devise_scope :user do
    get 'users/confirmation/new', to: 'devise/confirmations#new'
    get 'users/password/edit', to: 'devise/passwords#edit'
    get 'users/password/new', to: 'devise/passwords#new'
    get 'users/registration/edit', to: 'devise/registrations#edit'
    get 'users/registration/new', to: 'devise/registrations#new'
    get 'users/session/new', to: 'devise/sessions#new'
    get 'users/unlock/new', to: 'devise/unlocks#new'
    # Custom routes for profiles
    get 'profile/edit/:id', to: 'profiles#edit', as: :edit_profile
    patch 'profile', to: 'profiles#update'
    #get '/inventory', to: 'inventory#index'

  end
  # Resource routes for your models
  resources :wallets do
     member do
      post :add_shards
      post :subtract_shards
      get :buy_shards # Displays the shard purchase page
      post :purchase_shards # Processes the fake payment and updates wallet balance
     end
  end

  resources :transactions
  resources :items
  resources :inventories
  resources :servers
  resources :server_users, only: [:create, :destroy]
  resources :grid_cells
  resources :contents
  resources :treasures
  resources :treasure_finds
  resources :scores
  resources :leaderboards
  resources :leaderboard_entries

  # resources :servers do
  #   member do
  #     post 'start'
  #   end
  # end
  resources :items do
    member do
      post 'purchase'
    end
  end

  resources :servers do
    member do
      get 'start_game'
      post 'start_game'
      get 'join_game'
      post 'join_game'
    end
  end

  resources :games, only: [:show] do
    member do
      post :perform_action
      post :start_game
    end
  end
  mount ActionCable.server => '/cable'
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
