# frozen_string_literal: true

class AdminUser < ApplicationRecord
  has_many :products, foreign_key: 'author_id', class_name: 'AdminUser', inverse_of: 'auther', dependent: :nullify
  has_many :recipe_keywords, foreign_key: 'author_id', class_name: 'RecipeKeyword', inverse_of: 'auther', dependent: :nullify
end
