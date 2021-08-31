# frozen_string_literal: true

module V1
  class KitchenShoppingListsController < ApplicationController
    before_action :set_shopping_list, only: %i[update]

    api :GET, '/v1/kitchen_shopping_lists', 'Show shopping lists'
    def index
      render content_type: 'application/json', json: KitchenShoppingListSerializer.new(
        @current_user.kitchen.kitchen_shopping_lists.order(:created_at),
        include: association_for_lists,
        params: serializer_params
      ), status: :ok
    end

    api :POST, '/v1/kitchen_shopping_lists', 'Create shopping lists'
    param :kitchen_shopping_lists, Array, required: true, desc: 'Shopping lists' do
      param :product_id, :number, required: true, desc: "Parent product's id"
      param :note, String, allow_blank: true, desc: 'Note for list'
    end
    def create
      ksls = @current_user.kitchen_shopping_lists.build(shopping_list_create_params)
      kitchen = @current_user.kitchen
      ksls.each { |ksl| ksl.kitchen = kitchen }
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
      ids = params[:kitchen_shopping_list_ids]
      ksls = @current_user.kitchen.kitchen_shopping_lists.where(id: ids)
      destroyed = ksls.destroy_all
      render content_type: 'application/json', json: {
        data: { meta: { destroyed_count: destroyed.size } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_shopping_list
      @shopping_list = KitchenShoppingList.find(params[:id])
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
