# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    skip_before_action :authenticate_with_api_token, only: %i[verificate token]

    before_action :verificate_permission, only: %i[create]

    api :POST, '/admin/admin_users', 'Admin user registration'
    param :email, String, required: true, desc: 'Admin user email'
    def create
      onetime_pass = AdminUser.generate_pass_code.to_s
      admin_user = AdminUser.new(email: params[:email], password: onetime_pass, password_confirmation: onetime_pass)
      admin_user.save!
      render content_type: 'application/json', json: {
        data: { meta: { onetime_pass: onetime_pass } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/admin/verificate', 'Verificate admin user'
    param :email, String, required: true, desc: 'Admin user email'
    param :onetime_pass, String, required: true, desc: 'One time pass code'
    param :password, String, required: true, desc: 'Account password'
    param :password_confirmation, String, required: true, desc: 'Password confirmation'
    def verificate
      admin_user = AdminUser.find_by!(email: params[:email])
      raise ForbiddenError unless admin_user.authenticate(params[:onetime_pass])

      admin_user.assign_attributes(password: params[:password], password_confirmation: params[:password_confirmation])
      admin_user.save!
      admin_user_id = admin_user.id
      token = self.class.jwt_encode_for_general(subject: admin_user_id)
      render content_type: 'application/json', json: {
        data: {
          meta: {
            id: admin_user_id,
            token: token
          }
        }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/admin/token', 'Generate token'
    param :email, String, required: true, desc: 'Admin user email'
    param :password, String, required: true, desc: 'Current account password'
    def token
      admin_user = AdminUser.find_by!(email: params[:email])
      raise ForbiddenError unless admin_user.authenticate(params[:password])

      admin_user_id = admin_user.id
      token = self.class.jwt_encode_for_general(subject: admin_user_id)
      render content_type: 'application/json', json: {
        data: {
          meta: {
            id: admin_user_id,
            token: token
          }
        }
      }, status: :ok
    end

    private

    def verificate_permission
      raise ForbiddenError unless @admin_user.admin?
    end

    def admin_user_create_params
      params.permit(
        %i[
          email
        ]
      )
    end
  end
end
