# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    api :POST, '/admin/products', 'Product registration.'
    def create
      product = Product.new
      product.author = @admin_user
      product.product_category = ProductCategory.find(params[:product_category_id])
      product.save
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
