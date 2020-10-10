# frozen_string_literal: true

class RecipeCategoriesController < ApplicationController
  api :GET, '/', 'Nothing'
  def root
    render json: { status: 'SUCCESS', message: 'API Upgrade token' }
  end

  api :GET, '/recipe_categories', 'Show the recipe category'
  def index
    recipe_categories = RecipeCategory.all
    render json: { recipe_categories: recipe_categories }
  end
end
