# frozen_string_literal: true

module V1
  class RecipeFavoritesController < ApplicationController
    before_action :set_recipe

    api :POST, '/v1/recipes/:id/recipe_favorite', 'Make a recipe favorite'
    def create
      is_new_favorite = RecipeFavorite.where(recipe: @recipe, user: @current_user).empty?
      if is_new_favorite
        favorite = RecipeFavorite.new(recipe: @recipe, user: @current_user)
        favorite.save!
      end
      render content_type: 'application/json', json: {
        data: { meta: { is_new_favorite: is_new_favorite } }
      }, status: :ok
    end

    api :DELETE, '/v1/recipes/:id/recipe_favorite', 'Delete a recipe favorite'
    def destroy
      favorite = RecipeFavorite.find_by(recipe: @recipe, user: @current_user)
      is_exists = favorite.present?
      favorite.destroy! if is_exists
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: is_exists } }
      }, status: :ok
    end

    private

    def set_recipe
      @recipe = Recipe.find(params[:recipe_id])
    end
  end
end
