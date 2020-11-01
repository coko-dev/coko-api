# frozen_string_literal: true

class Kitchen < ApplicationRecord
  belongs_to :owner, foreign_key: 'owner_user_id', class_name: 'User', inverse_of: :own_kitchen

  has_many :kitchen_joins, dependent: :delete_all
  has_many :kitchen_ocr_histories, dependent: :delete_all
  has_many :kitchen_products, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :ktichen_shopping_lists, dependent: :delete_all
  has_many :users, dependent: :nullify
end
