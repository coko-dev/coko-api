# frozen_string_literal: true

class RecipeKeyword < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  belongs_to :author, class_name: 'AdminUser', inverse_of: 'recipe_keywords'

  has_many :hot_recipe_keywords, dependent: :delete_all
  has_many :recipe_keyword_lists, dependent: :delete_all
  has_many :recipes, through: :recipe_keyword_lists

  scope :publishable, -> { where(is_blacked: false).order(:name_hira) }
  scope :blacked, -> { where(is_blacked: true).order(:name_hira) }
end
