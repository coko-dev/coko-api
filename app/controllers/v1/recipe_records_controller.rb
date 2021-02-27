# frozen_string_literal: true

module V1
  class RecipeRecordsController < ApplicationController
    before_action :set_recipe_record, only: %i[show]

    api :GET, '/v1/recipe_records/:id', 'Show recipe record'
    def show
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
