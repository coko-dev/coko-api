# frozen_string_literal: true

class ProductCategory < ApplicationRecord
  validates :name_slug, presence: true, uniqueness: true

  belongs_to :parent_category, class_name: 'ProductCategory', optional: true

  has_many :child_categories, foreign_key: 'product_category_id_from', class_name: 'ProductCategory', inverse_of: 'parent_category', dependent: :nullify
  has_many :products, dependent: :nullify
end
