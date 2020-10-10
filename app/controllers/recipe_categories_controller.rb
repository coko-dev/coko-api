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

  api :POST, '/recipe_category', 'Create recipe category'
  def create
    recipe_category = RecipeCategory.new(recipe_category_params)
    if recipe_category.save
      render json: { status: 'SUCCESS', data: recipe_category }
    else
      render json: { status: 'ERROR', data: recipe_category.error }
    end
  end

  def recipe_category_params
    params.require(:recipe_category).permit(
      :name,
      :name_slug,
      :recipe_category_id
    )
  end
end
