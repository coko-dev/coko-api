# frozen_string_literal: true

module V1
  class RecipeCategoriesController < V1::ApplicationController
    api :GET, '/', 'Nothing'
    def root
      render json: { status: 'SUCCESS', message: 'api root path' }
    end

    api :GET, '/v1/recipe_categories', 'Show the recipe category'
    def index
      recipe_categories = RecipeCategory.all
      render json: { recipe_categories: recipe_categories }
    end

    api :POST, '/v1/recipe_categories', 'Create recipe categories'
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
end
