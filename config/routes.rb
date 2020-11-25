# frozen_string_literal: true

Rails.application.routes.draw do
  apipie

  namespace 'v1' do
    resources :recipe_categories, only: %i[index create]
    resources :users
    resources :user_profiles
  end

  namespace 'admin' do
    resources :admin_users
    resources :recipe_categories
  end
end
