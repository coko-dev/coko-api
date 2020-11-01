# frozen_string_literal: true

class Recipe
  belongs_to :auther, foreign_key: 'author_id', class_name: 'User', inverse_of: 'recipes'
  belongs_to :recipe_category

  has_many :recipe_favorite, dependent: :delete_all
  has_many :recipe_keywords, through: :recipe_keyword_lists
  has_many :recipe_keyword_lists, dependent: :delete_all
end
