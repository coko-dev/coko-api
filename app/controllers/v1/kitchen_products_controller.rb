# frozen_string_literal: true

module V1
  class KitchenProductsController < ApplicationController
    before_action :set_kitchen,                     only: %i[index create]
    before_action :set_kitchen_product,             only: %i[update destroy]
    before_action :verify_current_user_for_kitchen, only: %i[update destroy]

    api :GET, '/v1/kitchen_products', 'Get all products in own kitchen'
    def index
      kitchen_products = @kitchen.kitchen_products
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_products,
        include: associations_for_serialization
      ), status: :ok
    end

    api :POST, '/v1/kitchen_products', 'Create a kitchen product'
    param :product_id, :number, required: true, desc: 'Parent product\'s id'
    param :note, String, desc: "User's memo"
    param :best_before, String, desc: "Ex: '2021-10-5' or '2021-10-05'"
    def create
      product = Product.find(params[:product_id])
      kitchen_product = product.kitchen_products.build(kitchen_product_params)
      # NOTE: When building with params, no error occurs and it becomes nil.
      kitchen_product.best_before = params[:best_before].to_date
      kitchen_product.kitchen = @kitchen
      @kitchen.touch_with_history_build(user: @current_user, product: product, status_id: 'added')
      ApplicationRecord.transaction do
        kitchen_product.save!
        @kitchen.save!
      end
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_product,
        include: associations_for_serialization
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/kitchen_products/:id', 'Update a kitchen product'
    param :note, String, desc: "User's memo"
    param :best_before, String, desc: "Ex: '2021-10-5' or '2021-10-05'"
    def update
      @kitchen_product.assign_attributes(kitchen_product_params)
      # NOTE: When building with params, no error occurs and it becomes nil.
      @kitchen_product.best_before = params[:best_before].to_date
      is_changed = @kitchen_product.changed?
      if is_changed
        kitchen = @kitchen_product.kitchen.touch_with_history_build(user: @current_user, product: @kitchen_product.product, status_id: 'updated')
        ApplicationRecord.transaction do
          @kitchen_product.save!
          kitchen.save!
        end
      end
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        @kitchen_product,
        include: associations_for_serialization,
        meta: {
          is_changed: is_changed
        }
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :DELETE, '/v1/kitchen_products/:id', 'Delete a kitchen product'
    def destroy
      kitchen = @kitchen_product.kitchen.touch_with_history_build(user: @current_user, product: @kitchen_product.product, status_id: 'deleted')
      ApplicationRecord.transaction do
        @kitchen_product.destroy!
        kitchen.save!
      end
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: @kitchen_product.destroyed? } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def associations_for_serialization
      %i[
        product
      ]
    end

    # NOTE: Don't include 'best_before' in params to make an error if it cannot be converted to date type.
    def kitchen_product_params
      params.permit(
        %i[
          note
        ]
      )
    end

    def set_kitchen
      @kitchen = @current_user.kitchen
    end

    def set_kitchen_product
      @kitchen_product = KitchenProduct.find(params[:id])
    end

    def verify_current_user_for_kitchen
      kitchen = @kitchen_product.kitchen
      return if @current_user.my_kitchen?(kitchen)

      raise ForbiddenError
    end
  end
end
