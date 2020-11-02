# frozen_string_literal: true

class RecipeCategory < ApplicationRecord
  belongs_to :parent_category, class_name: 'RecipeCategory', optional: true

  has_many :child_categories, foreign_key: 'recipe_category_id_from', class_name: 'RecipeCategory', inverse_of: 'parent_category', dependent: :nullify
  has_many :recipes, dependent: :nullify
end
