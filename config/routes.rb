# config/routes.rb

Rails.application.routes.draw do
  root "static_pages#home"
  get "/about", to: "static_pages#about"
  mount ActionCable.server => '/cable'

  devise_for :users, controllers: { sessions: 'users/sessions' }

  devise_scope :user do
    get 'profile/:id', to: 'profiles#show', as: :user_root # Keep as user_root
    get 'profile/edit/:id', to: 'profiles#edit', as: :edit_profile
    patch 'profile', to: 'profiles#update'
  end

  resources :wallets do
    member do
      post :add_shards
      post :subtract_shards
      get :buy_shards
      post :purchase_shards
    end
  end

  resources :items do
    member do
      post :purchase
    end
  end

  resources :servers do
    member do
      post :start_game
      post :join_game
      post :generate_background
    end
    resources :server_users, only: [:create, :destroy] do
      collection do
        delete :leave
      end
    end
    resources :games do
      member do
        post 'perform_action', to: 'games#perform_action'
        get :current_turn
        get :update_game_board
        get :update_current_turn
        get :update_inventory
        get :update_treasures
        get :update_opponent_details
        get :update_player_stats
        get :update_game_area
        get :update_game_right_panel
        get :update_game_over
        get :update_show
        get :update_game_left_panel
      end
    end
  end

  resources :grid_cells
  resources :transactions
  resources :inventories
  resources :contents
  resources :treasures
  resources :treasure_finds
  resources :scores
  resources :leaderboards
  resources :leaderboard_entries

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
