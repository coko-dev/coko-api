# frozen_string_literal: true

module V1
  class KitchenShoppingListsController < ApplicationController
    api :GET, '/v1/kitchen_shopping_lists', 'Show shopping lists'
    def index
      ksls = @current_user.kitchen.kitchen_shopping_lists
      render content_type: 'application/json', json: KitchenShoppingListSerializer.new(
        ksls,
        include: association_for_lists
      ), status: :ok
    end

    api :POST, '/v1/kitchen_shopping_lists', 'Create shopping lists'
    param :kitchen_shopping_lists, Array, required: true, desc: 'Shopping lists' do
      param :product_id, :number, required: true, desc: "Parent product's id"
      param :note, String, allow_blank: true, desc: 'Note for list'
    end
    def create
      ksls = @current_user.kitchen_shopping_lists.build(shopping_list_params)
      kitchen = @current_user.kitchen
      ksls.each { |ksl| ksl.kitchen = kitchen }
      @current_user.save!
    end

    private

    def association_for_lists
      %i[
        product
        user
      ]
    end

    def shopping_list_params
      params.permit(
        kitchen_shopping_lists: %i[
          product_id
          note
        ]
      )&.values&.first
    end
  end
end
