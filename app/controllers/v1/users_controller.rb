# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user, only: %i[update show]

    skip_before_action :authenticate_with_api_token, only: %i[create]

    api :GET, '/v1/users/:code', 'Show user'
    param :code, User::CODE_REGEX, required: true, desc: 'User a code'
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
    def create
      user = User.new
      user.build_profile
      user.build_own_kitchen
      user.save!
      code = user.code
      klass = self.class
      token = Rails.env.development? ? klass.jwt_encode_for_general(subject: code) : klass.jwt_encode_for_firebase(subject: code)
      render content_type: 'application/json', json: UserSerializer.new(
        user,
        meta: { token: token }
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/users/:code', "Update user's profile"
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

    private

    def set_user
      @user = User.find_by!(code: params[:code])
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
