# frozen_string_literal: true

module V1
  module RecipeKeywords
    class RecipesController < ApplicationController
      before_action :set_keyword, only: %i[index]

      api :GET, '/v1/recipe_keywords/:recipe_keyword_id/recipes', 'Show some recipes related a keyword'
      def index
        recipes = @recipe_keyword.recipes.order(created_at: :desc).limit(12)
        render content_type: 'application/json', json: RecipeSerializer.new(
          recipes,
          include: association_for_recipes,
          params: serializer_params
        ), status: :ok
      end

      private

      def set_keyword
        @recipe_keyword = RecipeKeyword.find(params[:recipe_keyword_id])
      end

      def association_for_recipes
        %i[
          recipe_category
          author
        ]
      end

      def serializer_params
        {
          current_user: @current_user
        }
      end
    end
  end
end
