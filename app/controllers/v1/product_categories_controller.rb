# frozen_string_literal: true

module V1
  class ProductCategoriesController < ApplicationController
    api :GET, '/v1/product_categories', 'Show all product categories'
    def index
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        ProductCategory.all
      )
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
