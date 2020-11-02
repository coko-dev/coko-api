# frozen_string_literal: true

class RecipeRecord < ApplicationRecord
  belongs_to :author, class_name: 'User', inverse_of: 'recipe_records'
  belongs_to :recipe

  has_many :recipe_record_images, dependent: :delete_all
end
