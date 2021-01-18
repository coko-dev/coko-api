# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    api :POST, '/admin/products', 'Product registration.'
    def create
      # Process
    end
  end
end
