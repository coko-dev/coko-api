# frozen_string_literal: true

module Admin
  class RecipeKeywordsController < ApplicationController
    api :GET, '/admin/recipe_keywords', 'Show all publishable keywords'
    def index
      render content_type: 'application/json', json: RecipeKeywordSerializer.new(
        RecipeKeyword.publishable
      ), status: :ok
    end

    api :GET, '/admin/recipe_keywords/blacked', 'Show all blacked keywords'
    def show_blacked
      render content_type: 'application/json', json: RecipeKeywordSerializer.new(
        RecipeKeyword.blacked
      ), status: :ok
    end

    api :POST, '/admin/recipe_keywords', 'Create recipe keyword by admin'
    param :name, String, required: true, desc: "Keyword's name"
    param :name_hira, String, required: true, desc: "Keyword's name of Hiragana"
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
          name_hira
          is_blacked
        ]
      )
    end
  end
end
