# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    before_action :set_product,                only: %i[update]
    before_action :set_product_include_hidden, only: %i[hide publish]

    api :POST, '/admin/products', 'Product registration'
    param :name, String, require: true, desc: 'Product name'
    param :name_hira, String, desc: 'Product name of Hiragana'
    param :product_category_id, String, desc: 'Category id'
    def create
      product = Product.new(product_params)
      product.author = @admin_user
      product.product_category = ProductCategory.find(params[:product_category_id])
      product.save!
      render content_type: 'application/json', json: ProductSerializer.new(
        product
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/admin/products/:id', 'Product update'
    param :name, String, require: true, desc: 'Product name'
    param :name_hira, String, desc: 'Product name of Hiragana'
    param :product_category_id, String, desc: 'Category id'
    def update
      @product.update!(product_params)
      render content_type: 'application/json', json: ProductSerializer.new(
        @product
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PATCH, '/admin/products/:id/hide', 'Make a product hidden'
    def hide
      is_changed = @product.published?
      @product.hidden!
      # TODO: Include to serializer
      render content_type: 'application/json', json: {
        is_changed: is_changed
      }, status: :ok
    end

    api :PATCH, '/admin/products/:id/publish', 'Make a product published'
    def publish
      is_changed = @product.hidden?
      @product.published!
      # TODO: Include to serializer
      render content_type: 'application/json', json: {
        is_changed: is_changed
      }, status: :ok
    end

    def set_product
      @product = Product.published.find(params[:id])
    end

    def set_product_include_hidden
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        %i[
          name
          name_hira
          image
        ]
      )
    end
  end
end
