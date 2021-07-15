# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user_with_display_id, only: %i[show update]

    skip_before_action :authenticate_with_api_token, only: %i[create token]

    api :GET, '/v1/users/:display_id', 'Show user'
    param :display_id, String, required: true, desc: 'User display id'
    def show
      render content_type: 'application/json', json: UserSerializer.new(
        @user
      ), status: :ok
    end

    api :GET, '/v1/users/current', 'Show current user'
    def show_current_user
      render content_type: 'application/json', json: UserSerializer.new(
        @current_user
      ), status: :ok
    end

    api :POST, '/v1/users', 'User registration'
    param :display_id, String, required: true, desc: 'display id'
    param :password, String, required: true, desc: 'Account password'
    param :password_confirmation, String, required: true, desc: 'password confirmation'
    def create
      user = User.new(password: params[:password], password_confirmation: params[:password_confirmation])
      user.build_profile(display_id: params[:display_id])
      user.build_own_kitchen
      user.save!
      code = user.code
      klass = self.class
      token = Rails.env.development? ? klass.jwt_encode_for_general(subject: code, type: 'user') : klass.jwt_encode_for_firebase(user_code: code)
      render content_type: 'application/json', json: UserSerializer.new(
        user,
        meta: { token: token }
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/users/:display_id', "Update user's profile"
    param :display_id, String, allow_blank: true, desc: 'User display id'
    param :name, String, allow_blank: true, desc: 'User name'
    param :birth_date, String, allow_blank: true, desc: 'Birth date'
    param :housework_career, String, allow_blank: true, desc: 'housework_career'
    param :image, String, allow_blank: true, desc: 'User image url'
    param :description, String, allow_blank: true, desc: 'Description'
    param :website_url, String, allow_blank: true, desc: 'Website url(link)'
    def update
      authorize(@user)
      profile = @user.profile
      profile.assign_attributes(user_profile_params)
      @user.save!
      render content_type: 'application/json', json: UserSerializer.new(
        @user
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, 'v1/token', 'Generate token. Account password and (code or display_id) required'
    param :code, String, allow_blank: true, desc: 'User code'
    param :display_id, String, allow_blank: true, desc: 'User display id'
    param :password, String, required: true, desc: 'Current account password'
    def token
      params[:code].present? ? set_user_with_code : set_user_with_display_id

      raise ForbiddenError unless @user.authenticate(params[:password])

      user_code = @user.code
      klass = self.class
      token = Rails.env.development? ? klass.jwt_encode_for_general(subject: user_code, type: 'user') : klass.jwt_encode_for_firebase(user_code: user_code)
      render content_type: 'application/json', json: {
        data: {
          meta: {
            id: user_code,
            token: token
          }
        }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_user_with_code
      @user = User.find_by!(code: params[:code])
    end

    def set_user_with_display_id
      # TODO: eager load
      @user = UserProfile.find_by!(display_id: params[:display_id]).user
    end

    def user_params
      params.permit(
        %i[
          email
        ]
      )
    end

    def user_profile_params
      params.permit(
        %i[
          display_id
          name
          birth_date
          housework_career
          image
          description
          website_url
        ]
      )
    end

    def user_image_param
      params.permit(
        %i[
          base64_encoded_image
        ]
      )
    end
  end
end
