# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user, only: %i[update show]

    skip_before_action :authenticate_with_api_token, only: %i[create]

    api :GET, '/v1/users', 'Show user'
    param :code, User::CODE_REGEX, required: true, desc: 'User code'
    def show
      render content_type: 'application/json', json: UserSerializer.new(
        @user
      ), status: :ok
    end

    api :POST, '/v1/users', 'User registration'
    def create
      user = User.new(user_params)
      user.build_profile
      user.build_own_kitchen
      user.save!
      code = user.code
      token = self.class.jwt_encode(subject: code, type: 'user')
      # TODO: Move to Json serializer
      render content_type: 'application/json', json: {
        code: code,
        token: token
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    # TODO: Add image update.
    api :PUT, '/v1/users/:code', 'User profiles update'
    def update
      raise ForbiddenError if @current_user != @user

      @user.assign_attributes(user_params)
      profile = @user.profile
      profile.assign_attributes(user_profile_params)
      profile.upload_and_fetch_user_image(encoded_image: params[:base64_encoded_image]) if user_image_param.present?
      if @user.save
        render content_type: 'application/json', json: {
          message: 'Update completed.'
        }, status: :ok
      else
        errors = @user.errors.messages
        logger.error(errors)
        # NOTE: ユーザ向けバリデーションエラーを返す
        detail = errors.values.flatten.last
        render_manual_bad_request(detail)
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
        %i[
          display_id
          name
          birth_date
          housework_career
          description
          website_url
        ]
      )
    end

    def user_image_param
      params.permit(
        :base64_encoded_image
      )
    end
  end
end
