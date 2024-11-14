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

  # Resource routes for your models
  resources :wallets
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

  # Other routes...
end
