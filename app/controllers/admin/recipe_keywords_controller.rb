# frozen_string_literal: true

module Admin
  class RecipeKeywordsController < ApplicationController
    api :POST, '/admin/recipe_keywords', 'Create recipe keyword by admin'
    param :name, String, required: true, desc: "Keyword's name"
    param :is_blacked, [true, false], allow_blank: true, desc: 'Is it blacked word?. Default: false'
    def create
      recipe_keyword = @admin_user.recipe_keywords.build(recipe_keyword_params)
      recipe_keyword.save!
      render content_type: 'application/json', json: RecipeKeywordSerializer.new(
        recipe_keyword
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def recipe_keyword_params
      params.permit(
        %i[
          name
          is_blacked
        ]
      )
    end
  end
end
