# frozen_string_literal: true

Rails.application.routes.draw do
  apipie

  namespace 'v1' do
    resources :kitchen_joins, param: :code, only: %i[create] do
      member do
        patch '/verification', to: 'kitchen_joins#verification'
      end
      collection do
        patch '/confirm', to: 'kitchen_joins#confirm'
      end
    end
    resources :kitchen_products
    resources :kitchen_shopping_lists, only: %i[index create]
    delete 'kitchen_shopping_lists', to: 'kitchen_shopping_lists#destroy'

    resources :products, only: %i[index]
    resources :recipes do
      resources :recipe_records, only: %i[create], controller: 'recipes/recipe_records'
      member do
        post '/favorite', to: 'recipes#create_favorite'
        delete '/favorite', to: 'recipes#destroy_favorite'
      end
      collection do
        get '/latest', to: 'recipes#show_latest'
      end
    end
    resources :recipe_records
    resources :recipe_categories, only: %i[index show]
    resources :users, param: :code
    resources :user_profiles
  end

  namespace 'admin' do
    resources :admin_users
    resources :products do
      member do
        patch '/hide', to: 'products#hide'
      end
      member do
        patch '/publish', to: 'products#publish'
      end
    end
    resources :product_categories
    resources :recipe_categories
  end
end
