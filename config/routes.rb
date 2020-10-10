# frozen_string_literal: true

Rails.application.routes.draw do
  apipie

  resources :recipe_categories, only: %i[index create]

  root 'recipe_categories#root'
end
