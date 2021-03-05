# frozen_string_literal: true

module V1
  class RecipeRecordsController < ApplicationController
    before_action :set_recipe_record, only: %i[show update destroy]

    api :GET, '/v1/recipe_records', 'Show recipe record related to user own'
    def index
      recipe_records = @current_user.recipe_records.order(created_at: :desc)
      render content_type: 'application/json', json: RecipeRecordSerializer.new(
        recipe_records,
        include: associations_to_include
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :GET, '/v1/recipe_records/:id', 'Show a recipe record'
    def show
      render content_type: 'application/json', json: RecipeRecordSerializer.new(
        @recipe_record,
        include: associations_to_include
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/recipe_records/:id', 'Update a recipe record'
    param :body, String, desc: 'Record description'
    param :recipe_record_images, Array, allow_blank: true, desc: 'Record images' do
      param :image, String, required: true, desc: 'Recipe image url'
    end
    def update
      @recipe_record.assign_attributes(recipe_record_params)
      ApplicationRecord.transaction do
        if recipe_record_image_params.present?
          @recipe_record.recipe_record_images.destroy_all
          @recipe_record.build_each_images(recipe_record_image_params)
        end
        @recipe_record.save!
      end
      render content_type: 'application/json', json: RecipeRecordSerializer.new(
        @recipe_record,
        include: associations_to_include
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :DELETE, '/v1/recipe_records/:id', 'Delete a recipe record'
    def destroy
      @recipe_record.destroy!
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: @recipe_record.destroyed? } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_recipe_record
      @recipe_record = RecipeRecord.find(params[:id])
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
