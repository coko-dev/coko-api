# frozen_string_literal: true

module Admin
  class RecipeCategoriesController < ApplicationController
    before_action :set_recipe_category, only: %i[show]

    api :GET, '/admin/recipe_categories', 'Show all recipe category'
    def index
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        RecipeCategory.all
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    api :GET, '/admin/recipe_categories/:id', 'Show a recipe category'
    def show
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        @recipe_category
        # TODO: include related recipes
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/admin/recipe_categories', 'Create a recipe category'
    def create
      recipe_category = RecipeCategory.new(recipe_category_params)
      # NOTE: Use '.find_by' as parent_category_id can be null.
      recipe_category.parent_category = RecipeCategory.find_by(id: params[:parent_category_id])
      recipe_category.save!
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        recipe_category
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_recipe_category
      @recipe_category = RecipeCategory.find(params[:id])
    end

    def recipe_category_params
      params.permit(
        %i[
          name
          name_slug
        ]
      )
    end
  end
end
