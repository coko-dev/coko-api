# frozen_string_literal: true

module V1
  class KitchenRevenuecatsController < ApplicationController
    api :POST, 'v1/kitchen_revenuecat', 'Create revenuecat for self kitchen'
    def create
      kitchen = @current_user.kitchen
      raise StandardError, 'Not subscribed' unless RevenuecatClient.subscribed?(type: :kitchen, id: kitchen.id)

      kitchen.is_subscriber = true
      is_changed = kitchen.changed?
      kitchen.save!

      render content_type: 'application/json', json: {
        data: { meta: { is_became_subscriber: is_changed } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
