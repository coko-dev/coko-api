# frozen_string_literal: true

module V1
  module Recipes
    class RecipeRecordsController < ApplicationController
      before_action :set_recipe, only: %i[create]

      api :GET, '/v1/recipes/:recipe_id/recipe_records', 'Show recipe records related to a recipe'
      def index
        recipe_records = RecipeRecord.order(created_at: :desc).limit(12)
        render content_type: 'application/json', json: RecipeRecordSerializer.new(
          recipe_records,
          include: associations_to_include
        ), status: :ok
      end

      api :POST, '/v1/recipes/:recipe_id/recipe_records', 'Create recipe record'
      param :body, String, required: true, desc: 'Record description'
      param :recipe_record_images, Array, required: true, desc: 'Record images' do
        param :image, String, required: true, desc: 'Recipe image url'
      end
      def create
        recipe_record = @recipe.recipe_records.build(body: params[:body], author: @current_user)
        images_exists = recipe_record.build_each_images(recipe_record_image_params)
        raise StandardError unless images_exists

        recipe_record.save!
        render content_type: 'application/json', json: RecipeRecordSerializer.new(
          recipe_record,
          include: associations_to_include
        ), status: :ok
      rescue StandardError => e
        render_bad_request(e)
      end

      private

      def set_recipe
        @recipe = Recipe.find(params[:recipe_id])
      end

      def associations_to_include
        %i[
          recipe
          author
        ]
      end

      def recipe_record_params
        params.permit(
          %i[
            body
          ]
        )
      end

      def recipe_record_image_params
        params.permit(
          recipe_record_images: %i[
            image
          ]
        )&.values&.first
      end
    end
  end
end
