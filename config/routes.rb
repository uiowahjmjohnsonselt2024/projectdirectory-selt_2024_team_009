Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users

  # Define authenticated and unauthenticated root paths
  authenticated :user do
    root to: 'profiles#show', as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Define user_root_path
  devise_scope :user do
    get 'profile', to: 'profiles#show', as: :user_root
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
    get 'profile', to: 'profiles#show', as: :profile
    get 'profile/edit', to: 'profiles#edit', as: :edit_profile
    patch 'profile', to: 'profiles#update'
  end
  # Resource routes for your models
  resources :wallets #do
    # member do
    #  post :add_shards
    #  post :subtract_shards
    #end
    #end

  resources :transactions
  resources :items
  resources :inventories
  resources :servers
  resources :server_users
  resources :grid_cells
  resources :contents
  resources :treasures
  resources :treasure_finds
  resources :scores
  resources :leaderboards
  resources :leaderboard_entries

  resources :items do
    member do
      post :purchase
    end
  end


  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
