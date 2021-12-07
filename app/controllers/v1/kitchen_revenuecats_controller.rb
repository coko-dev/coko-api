# frozen_string_literal: true

module V1
  class KitchenRevenuecatsController < ApplicationController
    before_action :set_kitchen

    api :PUT, 'v1/kitchen_revenuecat', 'Update kitchen subscription status'
    def update
      response_body = RevenuecatClient.subscription(type: :kitchen, id: @kitchen.id)
      is_subscriber = response_body.present?
      subscription_expires_at = @kitchen.subscription_expires_at
      fetched_expires_date = response_body.dig(:subscriber, :subscriptions, RevenuecatClient.plan_name(response_body)&.to_sym, :expires_date)&.to_datetime if is_subscriber && (subscription_expires_at.blank? || subscription_expires_at&.past?)

      @kitchen.update!(is_subscriber: is_subscriber, subscription_expires_at: fetched_expires_date)
      render content_type: 'application/json', json: KitchenSerializer.new(
        @kitchen,
        include: associations_for_serialization,
        params: serializer_params,
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

    def associations_for_serialization
      %i[
        users
      ]
    end

    def serializer_params
      { current_user: @current_user }
    end
  end
end
