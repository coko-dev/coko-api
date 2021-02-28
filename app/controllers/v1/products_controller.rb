# frozen_string_literal: true

module V1
  class ProductsController < ApplicationController
    api :GET, '/v1/products', 'Show products'
    def index
      products = Product.published
      render content_type: 'application/json', json: ProductSerializer.new(
        products
      ), status: :ok
    end
  end
end
