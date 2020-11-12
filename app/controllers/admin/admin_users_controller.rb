# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    api :POST, '/admin/admin_users', 'Admin user registration.'
    def create
      admin_user = AdminUser.new(admin_user_params)
      if admin_user.save
        render content_type: 'application/json', json: {
          message: 'Completion of registration'
        }, status: :ok
      else
        errors = admin_user.errors
        messages = errors.messages
        logger.error(messages)
        render content_type: 'application/json', json: {
          errors: [{
            code: '400',
            title: 'Bad request',
            detail: errors.first.join
          }]
        }, status: :bad_request
      end
    end

    def admin_user_params
      params.permit(
        :email,
        :password,
        :password_confirmation
      )
    end
  end
end
