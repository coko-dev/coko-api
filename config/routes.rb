# frozen_string_literal: true

Rails.application.routes.draw do
  resources :recipe_categories
  root 'recipe_categories#index'
end
