# frozen_string_literal: true

module V1
  class RecipesController < ApplicationController
    api :POST, '/v1/recipes', 'Posting a recipe'
    param :name, String, required: true, desc: 'Recipe name'
    param :image, String, required: true, desc: 'Recipe image url'
    param :recipe_category_id, :number, required: true, desc: 'Parent category\'s id'
    param :cooking_time, String, required: true, desc: 'Minutes to cook'
    param :introduction, String, required: true, desc: 'Recipe introduction'
    param :advice, String, required: true, desc: 'Recipe advice'
    param :recipe_steps, Array, desc: 'Make recipe steps' do
      param :body, String, required: true, desc: 'Step description'
      param :image, String, allow_blank: true, desc: 'Step image url'
    end
    param :recipe_products, Array, desc: 'Products required for recipe' do
      param :product_id, :number, required: true, desc: 'Parent product\'s id'
      param :volume, String, allow_blank: true, desc: 'Amount to use'
      param :note, String, allow_blank: true, desc: 'Note for cook'
    end
    def create
      recipe = Recipe.new(recipe_create_params)
      recipe.author = @current_user
      recipe.recipe_category = RecipeCategory.find(params[:recipe_category_id])
      recipe.build_each_sections(introduction: params[:introduction], advice: params[:advice])
      products_exists = recipe.build_each_recipe_products(recipe_product_params).present?
      steps_exists = recipe.build_each_steps(recipe_step_params).present?
      raise StandardError unless products_exists && steps_exists

      recipe.save!
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def recipe_create_params
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
