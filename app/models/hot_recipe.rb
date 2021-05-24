# frozen_string_literal: true

class HotRecipe < ApplicationRecord
  belongs_to :recipe
  belongs_to :hot_recipe_version
end
