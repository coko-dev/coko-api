# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    include RenderErrorUtil

    before_action :set_user, only: %i[update]

    skip_before_action :authenticate_with_api_token, only: %i[create]

    api :POST, '/v1/users', 'User registration'
    def create
      user = User.new(user_params)
      user.build_profile
      user.build_own_kitchen
      if user.save
        code = user.code
        token = self.class.jwt_encode(subject: code, type: 'user')
        # TODO: Move to Json serializer
        render content_type: 'application/json', json: {
          user_code: code,
          token: token
        }, status: :ok
      else
        render_bad_request(user)
      end
    end

    # TODO: Add image update.
    api :PUT, '/v1/users/:code', 'User profiles update'
    def update
      @user.assign_attributes(user_params)
      profile = @user.profile
      profile.assign_attributes(user_profile_params)
      profile.image = UserProfile.upload_and_fetch_image(user_code: params[:code], image: params[:base64_encoded_image]) if user_image_param.present?
      if @user.save
        render content_type: 'application/json', json: {
          message: 'Update completed.'
        }, status: :ok
      else
        errors = @user.errors.messages
        logger.error(errors)
        # NOTE: ユーザ向けバリデーションエラーを返す
        detail = errors.values.flatten.last
        render_manual_bad_request('Bad request', detail)
      end
    end

    private

    def set_user
      @user = User.find_by!(code: params[:code])
    end

    def user_params
      params.permit(
        :email
      )
    end

    def user_profile_params
      params.permit(
        :user_id,
        :display_id,
        :name,
        :birth_date,
        :housework_career,
        :description,
        :website_url
      )
    end

    def user_image_param
      params.permit(
        :base64_encoded_image
      )
    end
  end
end
