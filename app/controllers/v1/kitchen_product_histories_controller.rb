# frozen_string_literal: true

module V1
  class KitchenProductHistoriesController < ApplicationController
    api :GET, '/v1/kitchen_product_histories', 'Show all product logs in own kitchen'
    def index
      histories = @current_user.kitchen.kitchen_product_histories.order(date: :desc, updated_at: :desc).limit(30)
      render content_type: 'application/json', json: KitchenProductHistorySerializer.new(
        histories,
        include: associations_for_serialization
      ), status: :ok
    end

    private

    def associations_for_serialization
      %i[
        user
        product
      ]
    end
  end
end
