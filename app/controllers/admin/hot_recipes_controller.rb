# frozen_string_literal: true

module Admin
  class HotRecipesController < ApplicationController
    before_action :set_recipe, only: %i[create destroy]
    before_action :set_version, only: %i[create destroy]

    api :POST, '/admin/hot_recipes', 'Register popular(hot) recipe'
    param :recipe_id, String, required: true, desc: "Parent recipe's id"
    param :version, String, required: true, desc: 'Version name'
    def create
      hot_recipe = HotRecipe.find_or_initialize_by(recipe: @recipe, hot_recipe_version: @version)
      hot_recipe.save!
      render content_type: 'application/json', json: RecipeSerializer.new(
        @recipe
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :DELETE, '/admin/hot_recipes', 'Destroy hot recipe relation'
    param :recipe_id, String, required: true, desc: "Parent recipe's id"
    param :version, String, required: true, desc: 'Version name'
    def destroy
      hot_recipe = HotRecipe.find_by!(recipe: @recipe, hot_recipe_version: @version).destroy!
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: hot_recipe.destroyed? } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_recipe
      @recipe = Recipe.published.find(params[:recipe_id])
    end

    def set_version
      @version = HotRecipeVersion.find_by!(version: params[:version])
    end

    def hot_recipe_params
      params.permit(
        %i[
          recipe_id
          version
        ]
      )
    end
  end
end
