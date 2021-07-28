# frozen_string_literal: true

module V1
  class RecipesController < ApplicationController
    before_action :set_recipe, only: %i[show update destroy]

    api :GET, '/v1/recipes', 'Show some recipes'
    param :hot_recipes, [true, false], allow_blank: true, desc: 'Show popular recipes. Default: false. Filtering will be skipped if `true`'
    param :recipe_category_id, :number, allow_blank: true, desc: 'Selected category id'
    param :user_id, String, allow_blank: true, desc: 'Selected user id'
    param :cooking_time_within, :number, allow_blank: true, desc: 'Cooking time limit'
    param :servings, :number, allow_blank: true, desc: 'How many servings'
    param :with_few_products, [true, false], allow_blank: true, desc: 'Find recipes with few products'
    param :can_be_made, [true, false], allow_blank: true, desc: 'Find recipes that you can make'
    def index
      recipes =
        if params[:hot_recipes].present?
          HotRecipeVersion.current.recipes
        else
          Recipe.narrow_down_recipes(recipe_narrow_down_params, @current_user)
        end

      render content_type: 'application/json', json: RecipeSerializer.new(
        recipes.published.order(created_at: :desc).limit(12),
        include: association_for_recipes
      ), status: :ok
    end

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
    param :cooking_time, :number, required: true, desc: 'Minutes to cook'
    param :servings, :number, required: true, desc: 'How many servings'
    param :introduction, String, required: true, desc: 'Recipe introduction'
    param :advice, String, required: true, desc: 'Recipe advice'
    param :recipe_keyword_ids, Array, allow_blank: true, desc: 'Recipe keyword ids. Ex: [1, 2, 3]'
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
      recipe.build_each_keywords(params[:recipe_keyword_ids])
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
    param :cooking_time, :number, allow_blank: true, desc: 'Minutes to cook'
    param :servings, :number, allow_blank: true, desc: 'How many servings'
    param :introduction, String, allow_blank: true, desc: 'Recipe introduction'
    param :advice, String, allow_blank: true, desc: 'Recipe advice'
    param :recipe_keyword_ids, Array, allow_blank: true, desc: 'Recipe keyword ids. Ex: [1, 2, 3]'
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
      authorize(@recipe)
      @recipe.assign_attributes(recipe_params)
      recipe_category_id = params[:recipe_category_id]
      @recipe.recipe_category = RecipeCategory.find(recipe_category_id) if recipe_category_id.present?
      ApplicationRecord.transaction do
        recipe_keyword_ids = params[:recipe_keyword_ids]
        if recipe_keyword_ids.present?
          @recipe.recipe_keyword_lists.destroy_all
          @recipe.build_each_keywords(recipe_keyword_ids)
        end
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

    private

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def association_for_a_recipe
      %i[
        hot_recipe_versions
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
          cooking_time
          servings
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

    def recipe_narrow_down_params
      params.permit(
        %i[
          recipe_category_id
          user_id
          cooking_time_within
          servings
          with_few_products
          can_be_made
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
