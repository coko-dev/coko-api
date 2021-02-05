# frozen_string_literal: true

module V1
  class RecipeCategoriesController < ApplicationController
    before_action :set_recipe_category, only: %i[show]

    api :GET, '/v1/recipe_categories', 'Show all recipe category'
    def index
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        RecipeCategory.all
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    api :GET, '/v1/recipe_categories/:id', 'Show a recipe category'
    def show
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        @recipe_category
        # TODO: include related recipes
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_recipe_category
      @recipe_category = RecipeCategory.find(params[:id])
    end
  end
end
