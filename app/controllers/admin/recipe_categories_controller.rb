# frozen_string_literal: true

module Admin
  class RecipeCategoriesController < ApplicationController
    api :GET, '/admin/recipe_categories', 'Show all recipe category'
    def index
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        RecipeCategory.all
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/admin/recipe_categories', 'Create a recipe category'
    param :name, String, required: true, desc: 'Category name for display'
    param :name_slug, String, required: true, desc: 'Category name slug'
    param :parent_category_id, :number, desc: "Parent category's key"
    def create
      recipe_category = RecipeCategory.new(recipe_category_params)
      parent_category_id = params[:parent_category_id]
      recipe_category.parent_category = RecipeCategory.find(parent_category_id) if parent_category_id.present?
      recipe_category.save!
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        recipe_category
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    private

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
