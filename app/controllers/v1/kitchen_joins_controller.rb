# frozen_string_literal: true

module V1
  class KitchenJoinsController < ApplicationController
    api :POST, '/v1/kitchen_joins', 'Create kitchen joins'
    def create
      kitchen_join = KitchenJoin.new(
        kitchen_id: @current_user.kitchen_id,
        expired_at: Time.zone.now + 5.minutes
      )

      if kitchen_join.save
        render content_type: 'application/json', json: {
          message: 'Completion of registration'
        }, status: :ok
      else
        errors = user.errors
        messages = errors.messages
        logger.error(messages)
        render content_type: 'application/json', json: {
          errors: [{
            code: '400',
            title: 'Bad request',
            detail: messages.first
          }]
        }, status: :bad_request
      end
    end
  end
end
