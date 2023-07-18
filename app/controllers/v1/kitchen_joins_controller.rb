# frozen_string_literal: true

require 'securerandom'

module V1
  class KitchenJoinsController < ApplicationController
    # 招待者用メソッド
    api :GET, '/v1/kitchen_joins/show_code', "Get the current user\'s invitation code or create one if it does not exist"
    def show_code
      @current_user.update!(invitation_code: SecureRandom.alphanumeric(10)) if @current_user.invitation_code.nil?

      render content_type: 'application/json', json: {
        invitation_code: @current_user.invitation_code
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PATCH, '/v1/kitchen_joins/refresh_code', 'Update the current user\'s invitation code'
    def refresh_code
      @current_user.update!(invitation_code: SecureRandom.alphanumeric(10))

      render json: { invitation_code: @current_user.invitation_code }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    # 被招待者用メソッド
    api :GET, '/v1/kitchen_joins/verify_code', 'Verify the invitation code and return the host name and kitchen name'
    param :invitation_code, String, required: true, desc: 'Invitation code to verify'
    def verify_code
      host = User.find_by!(invitation_code: params[:invitation_code])

      render json: { host_name: host.profile.name, kitchen_name: host.kitchen.name }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PATCH, '/v1/kitchen_joins/join', 'Join the kitchen using the provided invitation code'
    param :invitation_code, String, required: true, desc: 'Invitation code to join the kitchen'
    def join
      host = User.find_by!(invitation_code: params[:invitation_code])
      User.set_kitchen(user: @current_user, kitchen: host.kitchen)

      render json: { message: 'Successfully joined the kitchen.' }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
