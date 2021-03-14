# frozen_string_literal: true

module V1
  class RecipeKeywordsController < ApplicationController
    api :GET, '/admin/recipe_keywords', 'Show all publishable keywords'
    def index
      render content_type: 'application/json', json: RecipeKeywordSerializer.new(
        RecipeKeyword.publishable
      ), status: :ok
    end
  end
end
