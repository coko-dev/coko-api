# frozen_string_literal: true

class RecipeStep < ApplicationRecord
  belongs_to :recipe
end
