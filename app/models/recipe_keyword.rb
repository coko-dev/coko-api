# frozen_string_literal: true

class RecipeKeyword < Application
  belongs_to :auther, foreign_key: 'author_id', class_name: 'AdminUser', inverse_of: 'recipe_keywords'

  has_many :recipe_keyword_lists, dependent: :delete_all
  has_many :recipes, through: :recipe_keyword_lists
end
