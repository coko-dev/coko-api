# frozen_string_literal: true

module V1
  class KitchenJoinsController < ApplicationController
    include RenderErrorUtil

    api :POST, '/v1/kitchen_joins', 'Create kitchen joins'
    def create
      user_id = params[:user_id]
      raise StandardError if user_id.blank?

      kitchen_join = KitchenJoin.new(
        user_id: user_id,
        kitchen_id: @current_user.kitchen_id,
        expired_at: Time.zone.now + 3.minutes
      )

      if kitchen_join.save
        render content_type: 'application/json', json: {
          message: 'Completion of registration'
        }, status: :ok
      else
        render_bad_request(kitchen_join)
      end
    end

    # TODO: Add error handling.
    api :PATCH, '/v1/kitchen_joins/:code/verification', 'Verification kitchen join'
    def verification
      matched_kitchen_join = KitchenJoin.open.find_by!(code: params[:code], user_id: @current_user.id)
      kitchen = matched_kitchen_join.kitchen
      matched_kitchen_join.is_confirming = true
      if matched_kitchen_join.save
        render content_type: 'application/json', json: {
          message: 'Completion of registration',
          kitchen_name: kitchen.name
        }, status: :ok
      else
        errors = matched_kitchen_join.errors
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

    api :PATCH, '/v1/kitchen_joins/confirm', 'Confirm kitchen join'
    def confirm
      matched_kitchen_join = KitchenJoin.open.find_by!(user_id: @current_user.id)
      User.set_kitchen(user: @current_user, kitchen: matched_kitchen_join.kitchen)
      matched_kitchen_join.closed!

      render content_type: 'application/json', json: {
        message: 'Succeeded in participating in the kitchen'
      }, status: :ok
    rescue StandardError => e
      logger.error(e.messages)
    end
  end
end
