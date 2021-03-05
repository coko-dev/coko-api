# frozen_string_literal: true

module V1
  class RecipeRecordsController < ApplicationController
    before_action :set_recipe_record, only: %i[show update]

    api :GET, '/v1/recipe_records/:id', 'Show recipe record'
    def show
      render content_type: 'application/json', json: RecipeRecordSerializer.new(
        @recipe_record,
        include: association_for_a_record
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
        include: association_for_a_record
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_recipe_record
      @recipe_record = RecipeRecord.find(params[:id])
    end

    def association_for_a_record
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
