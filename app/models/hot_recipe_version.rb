# frozen_string_literal: true

class HotRecipeVersion < ApplicationRecord
  enum status_id: {
    enabled: 1,
    disabled: 2,
  }

  validates :version, uniqueness: true

  has_many :hot_recipes, dependent: :delete_all
  has_many :recipes, through: :hot_recipes
end
