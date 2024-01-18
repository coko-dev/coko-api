# frozen_string_literal: true

module V1
  class KitchenShoppingListsController < ApplicationController
    before_action :set_shopping_list, only: %i[update]
    before_action :set_kitchen, only: %i[index create destroy add_to_kitchen_products]

    api :GET, '/v1/kitchen_shopping_lists', 'Show shopping lists'
    def index
      render content_type: 'application/json', json: KitchenShoppingListSerializer.new(
        @kitchen.kitchen_shopping_lists.order(:created_at),
        include: association_for_lists,
        params: serializer_params
      ), status: :ok
    end

    api :POST, '/v1/kitchen_shopping_lists', 'Create shopping lists'
    param :kitchen_shopping_lists, Array, required: true, desc: 'Shopping lists' do
      param :product_id, String, required: true, desc: "Parent product's id"
      param :note, String, allow_blank: true, desc: 'Note for list'
    end
    def create
      raise StandardError, 'Add failed. Exceeds the maximum number' if @kitchen.is_subscriber.blank? && KitchenShoppingList.over_num_limit?(@kitchen, add_num: shopping_list_create_params.length)

      ksls = @current_user.kitchen_shopping_lists.build(shopping_list_create_params)
      ksls.each { |ksl| ksl.kitchen = @kitchen }
      @current_user.save!
      render content_type: 'application/json', json: KitchenShoppingListSerializer.new(
        ksls,
        include: association_for_lists,
        params: serializer_params
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/kitchen_shopping_lists/:id', 'Update shopping list'
    param :note, String, allow_blank: true, desc: 'Note for list'
    def update
      authorize(@shopping_list)
      @shopping_list.update!(shopping_list_update_params)
      render content_type: 'application/json', json: KitchenShoppingListSerializer.new(
        @shopping_list,
        include: association_for_lists,
        params: serializer_params
      ), status: :ok
    end

    api :DELETE, '/v1/kitchen_shopping_lists', 'Delete selected lists'
    param :kitchen_shopping_list_ids, Array, required: true, desc: 'Shopping list ids. Ex: [1, 2, 3]'
    def destroy
      ksls = @kitchen.kitchen_shopping_lists.where(id: params[:kitchen_shopping_list_ids])
      destroyed = ksls.destroy_all
      render content_type: 'application/json', json: {
        data: { meta: { destroyed_count: destroyed.size } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/v1/kitchen_shopping_lists/add_to_kitchen_products', 'Delete selected lists and create kitchen products'
    param :kitchen_shopping_list_ids, Array, required: true, desc: 'Shopping list ids. Ex: [1, 2, 3]'
    def add_to_kitchen_products
      ksls = @kitchen.kitchen_shopping_lists.where(id: params[:kitchen_shopping_list_ids])
      kitchen_products = ksls.map do |ksl|
        product = Product.find(ksl.product_id)
        @kitchen.touch_with_history_build(user: @current_user, product: product, status_id: 'added')
        @kitchen.kitchen_products.build(
          product: product,
          note: ksl.note
        )
      end
      ApplicationRecord.transaction do
        ksls.each(&:destroy!)
        @kitchen.save!
      end
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_products,
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

    def set_shopping_list
      @shopping_list = KitchenShoppingList.find(params[:id])
    end

    def set_kitchen
      @kitchen = @current_user.kitchen
    end

    def association_for_lists
      %i[
        product
        user
      ]
    end

    def serializer_params
      {
        current_user: @current_user
      }
    end

    def shopping_list_create_params
      params.permit(
        kitchen_shopping_lists: %i[
          product_id
          note
        ]
      )&.values&.first
    end

    def shopping_list_update_params
      params.permit(
        %i[
          note
        ]
      )
    end
  end
end
