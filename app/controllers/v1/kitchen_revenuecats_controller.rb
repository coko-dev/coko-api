# frozen_string_literal: true

module V1
  class KitchenRevenuecatsController < ApplicationController
    before_action :set_kitchen

    api :PUT, 'v1/kitchen_revenuecat', 'Update kitchen subscription status'
    def update
      is_subscriber = RevenuecatClient.subscribed?(type: :kitchen, id: @kitchen.id)
      @kitchen.update!(is_subscriber: is_subscriber)

      render content_type: 'application/json', json: KitchenSerializer.new(
        @kitchen,
        meta: {
          is_changed: @kitchen.saved_changes?
        }
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_kitchen
      @kitchen = @current_user.kitchen
    end
  end
end
