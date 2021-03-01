# frozen_string_literal: true

class ProductCategorySerializer < ApplicationSerializer
  attribute :name, :name_slug

  belongs_to :parent_category do |object|
    object&.parent_category
  end

  has_many :child_categories do |object|
    object&.child_categories
  end
end
