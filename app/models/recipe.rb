# frozen_string_literal: true

class Recipe < ApplicationRecord
  belongs_to :author, class_name: 'User', inverse_of: 'recipes'
  belongs_to :recipe_category

  has_many :recipe_favorite, dependent: :delete_all
  has_many :recipe_keyword_lists, dependent: :delete_all
  has_many :recipe_keywords, through: :recipe_keyword_lists
  has_many :recipe_products, dependent: :delete_all
  has_many :products, through: :recipe_products
  has_many :recipe_records, dependent: :delete_all
end
