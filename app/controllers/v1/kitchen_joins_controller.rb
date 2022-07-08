# frozen_string_literal: true

module V1
  class KitchenJoinsController < ApplicationController
    api :POST, '/v1/kitchen_joins', 'Create kitchen joins'
    param :user_code, String, required: true, desc: 'code of a user to invite'
    def create
      authorize :application, :account_based?

      user = User.find_by!(code: params[:user_code])

      kitchen_join = KitchenJoin.new(
        user: user,
        kitchen: @current_user.kitchen,
        expired_at: Time.zone.now + 3.minutes
      )

      kitchen_join.save!
      render content_type: 'application/json', json: {
        join_code: kitchen_join.code
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PATCH, '/v1/kitchen_joins/:code/verification', 'Verification kitchen join'
    def verification
      authorize :application, :account_based?

      matched_kitchen_join = KitchenJoin.open.find_by!(code: params[:code], user: @current_user)
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
      matched_kitchen_join = KitchenJoin.open.find_by!(user: @current_user)
      User.set_kitchen(user: @current_user, kitchen: matched_kitchen_join.kitchen)
      matched_kitchen_join.closed!

      render content_type: 'application/json', json: {
        message: 'Succeeded in participating in the kitchen'
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
