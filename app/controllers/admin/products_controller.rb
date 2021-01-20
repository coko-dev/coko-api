# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    api :POST, '/admin/products', 'Product registration'
    param :name, String, require: true, desc: 'Product name'
    param :name_hira, String, desc: 'Product name of Hiragana'
    param :product_category_id, String, desc: 'Category id'
    def create
      product = Product.new(product_params)
      product.author = @admin_user
      product.product_category = ProductCategory.find(params[:product_category_id])
      # TODO: Upload image.
      if product.save
        render content_type: 'application/json', json: ProductSerializer.new(
          product
        ), status: :ok
      else
        render_bad_request(object: product)
      end
    end

    api :PUT, '/admin/products/:id', 'Product update'
    param :name, String, require: true, desc: 'Product name'
    param :name_hira, String, desc: 'Product name of Hiragana'
    param :product_category_id, String, desc: 'Category id'
    def update
      product = Product.find(params[:id])
      product.assign_attributes(product_params)
      # TODO: Upload image.
      if product.save
        render content_type: 'application/json', json: ProductSerializer.new(
          product
        ), status: :ok
      else
        render_bad_request(object: product)
      end
    end

    def product_params
      params.require(:product).permit(
        %i[
          name
          name_hira
        ]
      )
    end

    def product_image_param
      params.permit(
        :base64_encoded_image
      )
    end
  end
end
