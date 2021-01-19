# frozen_string_literal: true

class ProductSerializer < ApplicationSerializer
  attributes :name, :name_hira, :product_category_id

  attribute :image_url do |object|
    object&.image
  end
end
