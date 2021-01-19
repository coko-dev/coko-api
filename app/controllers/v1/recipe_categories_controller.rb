# frozen_string_literal: true

module V1
  class RecipeCategoriesController < ApplicationController
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
        render_bad_request(object: recipe_category)
      end
    end

    def recipe_category_params
      params.require(:recipe_category).permit(
        %i[
          name
          name_slug
          recipe_category_id
        ]
      )
    end
  end
end
