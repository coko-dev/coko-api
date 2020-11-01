# frozen_string_literal: true

class RecipeKeywordList < ApplicationRecord
  belongs_to :recipe
  belongs_to :recipe_keyword
end
