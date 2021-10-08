# frozen_string_literal: true

module V1
  class KitchenRevenuecatsController < ApplicationController
    before_action :set_kitchen

    api :POST, 'v1/kitchen_revenuecat', 'Create subscription status'
    def create
      raise StandardError, 'Not subscribed' unless RevenuecatClient.subscribed?(type: :kitchen, id: @kitchen.id)

      @kitchen.update!(is_subscriber: true)

      render content_type: 'application/json', json: {
        data: { meta: { is_new_subscriber: @kitchen.saved_changes? } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :DELETE, 'v1/kitchen_revenuecat', 'Delete subscription status'
    def destroy
      raise StandardError, 'Did not delete subscription status. You are currently subscribed' if RevenuecatClient.subscribed?(type: :kitchen, id: @kitchen.id)

      @kitchen.update!(is_subscriber: false)

      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: @kitchen.saved_changes? } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_kitchen
      @kitchen = @current_user.kitchen
    end
  end
end
