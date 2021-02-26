# frozen_string_literal: true

module V1
  class RecipesController < ApplicationController
    before_action :set_recipe, only: %i[show update destroy create_favorite destroy_favorite]

    api :GET, '/v1/recipes/:id', 'Show a recipe'
    def show
      render content_type: 'application/json', json: RecipeSerializer.new(
        @recipe,
        include: association_for_a_recipe
      ), status: :ok
    end

    api :POST, '/v1/recipes', 'Posting a recipe'
    param :name, String, required: true, desc: 'Recipe name'
    param :image, String, required: true, desc: 'Recipe image url'
    param :recipe_category_id, :number, required: true, desc: "Parent category's id"
    param :cooking_time, String, required: true, desc: 'Minutes to cook'
    param :introduction, String, required: true, desc: 'Recipe introduction'
    param :advice, String, required: true, desc: 'Recipe advice'
    param :recipe_steps, Array, required: true, desc: 'Make recipe steps' do
      param :body, String, required: true, desc: 'Step description'
      param :image, String, allow_blank: true, desc: 'Step image url'
    end
    param :recipe_products, Array, required: true, desc: 'Products required for recipe' do
      param :product_id, :number, required: true, desc: "Parent product's id"
      param :volume, String, allow_blank: true, desc: 'Amount to use'
      param :note, String, allow_blank: true, desc: 'Note for cook'
    end
    def create
      recipe = Recipe.new(recipe_params)
      recipe.author = @current_user
      recipe.recipe_category = RecipeCategory.find(params[:recipe_category_id])
      recipe.build_or_update_each_sections(introduction: params[:introduction], advice: params[:advice])
      products_exists = recipe.build_each_recipe_products(recipe_product_params).present?
      steps_exists = recipe.build_each_steps(recipe_step_params).present?
      raise StandardError unless products_exists && steps_exists

      recipe.save!
      render content_type: 'application/json', json: RecipeSerializer.new(
        recipe,
        include: association_for_a_recipe
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/recipes/:id', 'Update a recipe'
    param :name, String, allow_blank: true, desc: 'Recipe name'
    param :image, String, allow_blank: true, desc: 'Recipe image url'
    param :recipe_category_id, :number, allow_blank: true, desc: "Parent category's id"
    param :cooking_time, String, allow_blank: true, desc: 'Minutes to cook'
    param :introduction, String, allow_blank: true, desc: 'Recipe introduction'
    param :advice, String, allow_blank: true, desc: 'Recipe advice'
    param :recipe_steps, Array, allow_blank: true, desc: 'Make recipe steps' do
      param :body, String, required: true, desc: 'Step description'
      param :image, String, allow_blank: true, desc: 'Step image url'
    end
    param :recipe_products, Array, allow_blank: true, desc: 'Products required for recipe' do
      param :product_id, :number, required: true, desc: "Parent product's id"
      param :volume, String, allow_blank: true, desc: 'Amount to use'
      param :note, String, allow_blank: true, desc: 'Note for cook'
    end
    def update
      @recipe.assign_attributes(recipe_params)
      @recipe.recipe_category = RecipeCategory.find(params[:recipe_category_id])
      ApplicationRecord.transaction do
        @recipe.build_or_update_each_sections(introduction: params[:introduction], advice: params[:advice])
        if recipe_product_params.present?
          @recipe.recipe_products.destroy_all
          @recipe.build_each_recipe_products(recipe_product_params)
        end
        if recipe_step_params.present?
          @recipe.recipe_steps.destroy_all
          @recipe.build_each_steps(recipe_step_params)
        end
        @recipe.save!
      end
      render content_type: 'application/json', json: RecipeSerializer.new(
        @recipe,
        include: association_for_a_recipe
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :DELETE, '/v1/recipes/:id', 'Delete a recipe'
    def destroy
      @recipe.destroy!
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: @recipe.destroyed? } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :GET, '/v1/recipes/latest', 'Show latest recipes'
    def show_latest
      recipes = Recipe.all.order(created_at: :desc).limit(8)
      render content_type: 'application/json', json: RecipeSerializer.new(
        recipes,
        include: association_for_recipes
      ), status: :ok
    end

    api :POST, '/v1/recipes/:id/favorite', 'Make a recipe favorite'
    def create_favorite
      is_new_favorite = RecipeFavorite.where(recipe: @recipe, user: @current_user).empty?
      if is_new_favorite
        favorite = RecipeFavorite.new(recipe: @recipe, user: @current_user)
        favorite.save!
      end
      render content_type: 'application/json', json: {
        data: { meta: { is_new_favorite: is_new_favorite } }
      }, status: :ok
    end

    api :DELETE, '/v1/recipes/:id/favorite', 'Delete a recipe favorite'
    def destroy_favorite
      favorite = RecipeFavorite.find_by(recipe: @recipe, user: @current_user)
      is_exists = favorite.present?
      favorite.destroy! if is_exists
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: is_exists } }
      }, status: :ok
    end

    private

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def association_for_a_recipe
      %i[
        recipe_steps
        recipe_products.product
        recipe_category
        author
      ]
    end

    def association_for_recipes
      %i[
        recipe_category
        author
      ]
    end

    def recipe_params
      params.permit(
        %i[
          name
          image
          imagecooking_time
        ]
      )
    end

    def recipe_section_params
      params.permit(
        %i[
          introduction
          advice
        ]
      )
    end

    def recipe_step_params
      params.permit(
        recipe_steps: %i[
          body
          image
        ]
      )&.values&.first
    end

    def recipe_product_params
      params.permit(
        recipe_products: %i[
          volume
          note
          product_id
        ]
      )&.values&.first
    end
  end
end
