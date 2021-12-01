# frozen_string_literal: true

class ProductSerializer < ApplicationSerializer
  attributes :name, :name_hira

  attribute :image_url do |object|
    object&.image
  end

  belongs_to :product_category
end
