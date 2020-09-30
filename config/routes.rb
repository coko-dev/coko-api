# frozen_string_literal: true

Rails.application.routes.draw do
  resources :recipe_categories, only: [:index]
  root 'recipe_categories#root'
end
