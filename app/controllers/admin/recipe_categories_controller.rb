# frozen_string_literal: true

module Admin
  class RecipeCategoriesController < ApplicationController
    before_action :set_recipe_category, only: %i[update]

    api :GET, '/admin/recipe_categories', 'Show all recipe category'
    def index
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        RecipeCategory.all
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/admin/recipe_categories', 'Create a recipe category'
    param :name, String, required: true, desc: 'Category name for display'
    param :name_slug, String, required: true, desc: 'Category name slug'
    param :parent_category_id, String, desc: "Parent category's key"
    def create
      recipe_category = RecipeCategory.new(recipe_category_params)
      parent_category_id = params[:parent_category_id]
      recipe_category.parent_category = RecipeCategory.find(parent_category_id) if parent_category_id.present?
      recipe_category.save!
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        recipe_category
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/admin/recipe_categories', 'Update recipe category'
    param :name, String, allow_blank: true, desc: 'Category name for display'
    param :name_slug, String, allow_blank: true, desc: 'Category name slug'
    param :parent_category_id, String, allow_blank: true, desc: "Parent recipe's key"
    def update
      @recipe_category.assign_attributes(recipe_category_params)
      parent_category_id = params[:parent_category_id]
      @recipe_category.parent_category = RecipeCategory.find(parent_category_id) if parent_category_id.present?
      @recipe_category.save!
      render content_type: 'application/json', json: RecipeCategorySerializer.new(
        @recipe_category
      ), status: :ok
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
