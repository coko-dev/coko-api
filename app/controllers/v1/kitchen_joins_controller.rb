# frozen_string_literal: true

module V1
  class KitchenJoinsController < ApplicationController
    api :POST, '/v1/kitchen_joins', 'Create kitchen joins'
    param :user_id, :number, required: true, desc: 'id of a user to invite'
    def create
      user = User.find(params[:user_id])

      kitchen_join = KitchenJoin.new(
        user: user,
        kitchen_id: @current_user.kitchen_id,
        expired_at: Time.zone.now + 3.minutes
      )

      kitchen_join.save!
      render content_type: 'application/json', json: {
        message: 'Completion of registration'
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    # TODO: Add error handling.
    api :PATCH, '/v1/kitchen_joins/:code/verification', 'Verification kitchen join'
    def verification
      matched_kitchen_join = KitchenJoin.open.find_by!(code: params[:code], user_id: @current_user.id)
      kitchen = matched_kitchen_join.kitchen
      matched_kitchen_join.is_confirming = true
      matched_kitchen_join.save!
      render content_type: 'application/json', json: {
        message: 'Completion of registration',
        kitchen_name: kitchen.name
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
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
