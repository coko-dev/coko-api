# frozen_string_literal: true

module V1
  class KitchenProductsController < ApplicationController
    before_action :set_kitchen
    before_action :verify_current_user_for_kitchen, only: %i[index]

    api :GET, '/v1/kitchen_products', 'Get all products in own kitchen'
    def index
      kitchen_products = @kitchen.kitchen_products
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_products,
        include: associations_for_serialization
      ), status: :ok
    end

    api :POST, '/v1/kitchen_products', 'Create a kitchen product'
    def create
      product = Product.find(params[:product_id])
      kitchen_product = product.kitchen_products.build(kitchen_product_params)
      # NOTE: When building with params, no error occurs and it becomes nil.
      kitchen_product.best_before = params[:best_before].to_date
      kitchen_product.kitchen = @kitchen
      kitchen_product.save!
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_product,
        include: associations_for_serialization
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def associations_for_serialization
      %i[
        product
      ]
    end

    def kitchen_product_params
      params.permit(
        :note
      )
    end

    def set_kitchen
      @kitchen = @current_user.kitchen
    end

    def verify_current_user_for_kitchen
      return if @current_user.my_kitchen?(@kitchen)

      raise ForbiddenError
    end
  end
end
