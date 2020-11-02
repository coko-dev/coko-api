# frozen_string_literal: true

class AdminUser < ApplicationRecord
  has_many :products, foreign_key: 'author_id', class_name: 'AdminUser', inverse_of: 'author', dependent: :nullify
  has_many :recipe_keywords, foreign_key: 'author_id', class_name: 'RecipeKeyword', inverse_of: 'author', dependent: :nullify
end
