# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :product_category
  belongs_to :auther, foreign_key: 'author_id', class_name: 'AdminUser', inverse_of: 'products'

  has_many :kitchen_products, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :product_ocr_strings, dependent: :delete_all
  has_many :recipe_products, dependent: :delete_all
  has_many :recipes, through: :recipe_products
end
