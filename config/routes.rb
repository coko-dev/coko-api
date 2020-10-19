# frozen_string_literal: true

Rails.application.routes.draw do
  apipie

  namespace 'v1' do
    resources :recipe_categories, only: %i[index create]
  end

  namespace 'admin' do
    resources :recipe_categories
  end
end
