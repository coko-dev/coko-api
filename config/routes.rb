# frozen_string_literal: true

Rails.application.routes.draw do
  apipie

  namespace :v1 do
    resource :kitchen, only: %i[update]
    resources :kitchens do
      collection do
        get 'current', to: 'kitchens#show_current_kitchen'
      end
    end
    resources :kitchen_joins, param: :code, only: %i[create] do
      member do
        patch 'verification', to: 'kitchen_joins#verification'
      end
      collection do
        patch 'confirm', to: 'kitchen_joins#confirm'
      end
    end
    resources :kitchen_products, only: %i[index create update]
    delete 'kitchen_products', to: 'kitchen_products#destroy'
    resources :kitchen_product_histories, only: %i[index]
    resource :kitchen_revenuecat, only: %i[update]
    resources :kitchen_shopping_lists, only: %i[index create update]
    delete 'kitchen_shopping_lists', to: 'kitchen_shopping_lists#destroy'

    resources :products, only: %i[index]
    resources :product_categories, only: %i[index]
    resources :product_requests, only: %i[create]
    resources :recipes do
      resources :recipe_records, only: %i[index create], controller: 'recipes/recipe_records'
      resource :recipe_favorite, only: %i[create destroy]
      collection do
        get 'latest', to: 'recipes#show_latest'
      end
    end
    resources :recipe_keywords do
      resources :recipes, only: %i[index], controller: 'recipe_keywords/recipes'
    end
    resources :recipe_records
    resources :recipe_categories, only: %i[index show]
    resources :service_requests, only: %i[create]
    resource :user, only: %i[update destroy]
    resources :users, param: :display_id, only: %i[show create] do
      resources :recipe_records, only: %i[index], controller: 'users/recipe_records'
      collection do
        get 'current',   to: 'users#show_current_user'
        get 'blockings', to: 'user_follows#show_blockings'
        get 'mutings',   to: 'user_follows#show_mutings'
      end
      member do
        get    'followers',  to: 'user_follows#show_followers'
        get    'followings', to: 'user_follows#show_followings'
        post   'follow',     to: 'user_follows#create'
        delete 'unfollow',   to: 'user_follows#destroy'
        post   'block',      to: 'user_follows#block'
        delete 'unblock',    to: 'user_follows#unblock'
        post   'mute',       to: 'user_follows#mute'
        delete 'unmute',     to: 'user_follows#unmute'
      end
    end
    resources :violation_reports, only: %i[create]
  end
end
