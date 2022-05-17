# frozen_string_literal: true

module V1
  class ProductCategoriesController < ApplicationController
    api :GET, '/v1/product_categories', 'Show all product categories'
    def index
      product_categories = ProductCategory.order(position: 'ASC').reject { |category| category.products.empty? }
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        product_categories
      )
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
