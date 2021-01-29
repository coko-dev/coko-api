# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    skip_before_action :authenticate_with_api_token, only: %i[create]

    api :POST, '/admin/admin_users', 'Admin user registration'
    def create
      admin_user = AdminUser.new(admin_user_params)
      admin_user.save!
      admin_user_id = admin_user.id
      token = self.class.jwt_encode(subject: admin_user_id, type: 'admin_user')
      render content_type: 'application/json', json: {
        id: admin_user_id,
        token: token
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    def admin_user_params
      params.permit(
        %i[
          email
          password
          password_confirmation
        ]
      )
    end
  end
end
