# frozen_string_literal: true
require 'securerandom'

module V1
  class KitchenJoinsController < ApplicationController
    api :POST, '/v1/kitchen_joins', 'Create kitchen joins'
    param :user_code, String, required: true, desc: 'code of a user to invite'
    def create
      guest = User.find_by!(code: params[:user_code])
      @current_user.update(invitation_code: SecureRandom.alphanumeric(10))

      render content_type: 'application/json', json: {
        code: @current_user.invitation_code
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PATCH, '/v1/kitchen_joins/:code/verification', 'Verification kitchen join'
    def verification
      inviter = User.find_by!(invitation_code: params[:code])
      kitchen = Kitchen.find_by!(id: inviter.kitchen)
      render content_type: 'application/json', json: {
        message: 'Completion of registration',
        code: inviter.invitation_code,
        kitchen: kitchen
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PATCH, '/v1/kitchen_joins/confirm', 'Confirm kitchen join'
    def confirm
      inviter = User.find_by!(invitation_code: params[:code])
      User.set_kitchen(user: @current_user, kitchen: inviter.kitchen)

      render content_type: 'application/json', json: {
        message: 'Succeeded in participating in the kitchen'
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
