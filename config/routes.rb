# frozen_string_literal: true

Rails.application.routes.draw do
  apipie

  namespace 'v1' do
    resources :recipe_categories, only: %i[index create]
    resources :users
  end

  namespace 'admin' do
    resources :admin_users
    resources :recipe_categories
  end
end
