# frozen_string_literal: true

class Kitchen < ApplicationRecord
  has_many :kitchen_joins, dependent: :delete_all
  has_many :kitchen_ocr_histories, dependent: :delete_all
  has_many :kitchen_products, dependent: :delete_all
  has_many :users, dependent: :nullify
end
