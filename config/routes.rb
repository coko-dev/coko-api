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
    resources :recipe_categories, only: %i[index create]
    resources :users, param: :code
    resources :user_profiles
  end

  namespace 'admin' do
    resources :admin_users
    resources :products
    resources :recipe_categories
  end
end
