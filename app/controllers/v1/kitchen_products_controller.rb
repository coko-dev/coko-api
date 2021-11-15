# frozen_string_literal: true

module V1
  class KitchenProductsController < ApplicationController
    before_action :set_kitchen,                     only: %i[index create]
    before_action :set_kitchen_product,             only: %i[update destroy]

    api :GET, '/v1/kitchen_products', 'Show all products in own kitchen'
    def index
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        @kitchen.kitchen_products.order(:created_at),
        include: associations_for_serialization
      ), status: :ok
    end

    api :POST, '/v1/kitchen_products', 'Create a kitchen product'
    param :kitchen_products, Array, required: true, desc: 'Products' do
      param :product_id, :number, required: true, desc: "Parent product's id"
      param :note, String, desc: "User's memo"
      param :added_on, String, desc: "Ex: '2021-10-5' or '2021-10-05'. Default: request date"
      param :best_before, String, desc: "Ex: '2021-10-5' or '2021-10-05'"
    end
    def create
      kitchen_products = @kitchen.kitchen_products.build(kitchen_product_create_params)
      kitchen_products.zip(kitchen_product_params).each do |kitchen_product, kitchen_product_param|
        # NOTE: When building with params, no error occurs and it becomes nil.
        kitchen_product.added_on = kitchen_product_param[:added_on]&.to_date
        kitchen_product.best_before = kitchen_product_param[:best_before]&.to_date
        @kitchen.touch_with_history_build(user: @current_user, product: product, status_id: 'added')
      end
      @kitchen.save!
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_products,
        include: associations_for_serialization
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/kitchen_products/:id', 'Update a kitchen product'
    param :note, String, desc: "User's memo"
    param :added_on, String, desc: "Ex: '2021-10-5' or '2021-10-05'. Default: request date"
    param :best_before, String, desc: "Ex: '2021-10-5' or '2021-10-05'"
    def update
      authorize(@kitchen_product)
      @kitchen_product.assign_attributes(kitchen_product_update_params)
      # NOTE: When building with params, no error occurs and it becomes nil.
      added_on = params[:added_on]
      @kitchen_product.added_on = added_on.to_date if added_on.present?
      best_before = params[:best_before]
      @kitchen_product.best_before = best_before.to_date if best_before.present?
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
      authorize(@kitchen_product)
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

    def kitchen_product_params
      params.permit(
        %i[
          product_id
          note
          added_on
          best_before
        ]
      )
    end

    # NOTE: Don't include 'best_before' in params to make an error if it cannot be converted to date type.
    def kitchen_product_update_params
      params.permit(
        %i[
          note
        ]
      )
    end

    def kitchen_product_create_params
      params.permit(
        kitchen_products: %i[
          product_id
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
  end
end
