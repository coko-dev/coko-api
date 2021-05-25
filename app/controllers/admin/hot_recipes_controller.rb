# frozen_string_literal: true

module Admin
  class HotRecipesController < ApplicationController
    api :POST, '/admin/hot_recipes', 'Register popular recipe'
    param :recipe_id, :number, required: true, desc: "Parent recipe's id"
    param :version, String, required: true, desc: "Ex: '2021-10-5' or '2021-10-05'"
    def create
      hot_recipe = @recipe.hot_recipes.build
      hot_recipe.version = params[:added_on].to_date
      hot_recipe.save!
      render content_type: 'application/json', json: ProductSerializer.new(
        hot_recipe
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_recipe
      @recipe = Recipe.published.find(params[:recipe_id])
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
