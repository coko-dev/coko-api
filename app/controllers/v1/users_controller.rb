# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user_with_display_id, only: %i[show]

    skip_before_action :authenticate_with_api_token, only: %i[create]

    api :GET, '/v1/users/:display_id', 'Show user'
    param :display_id, String, required: true, desc: 'User display id'
    def show
      render content_type: 'application/json', json: UserSerializer.new(
        @user,
        params: serializer_params
      ), status: :ok
    end

    api :GET, '/v1/users/current', 'Show current user'
    def show_current_user
      render content_type: 'application/json', json: UserSerializer.new(
        @current_user,
        params: serializer_params
      ), status: :ok
    end

    api :POST, '/v1/users', 'User registration'
    def create
      payload = authenticate_or_request_with_http_token { |token, _option| self.class.jwt_decode_for_firebase(token) }

      user = User.new(code: payload[:sub])
      user.build_profile(name: payload[:name] || '', image: payload[:picture] || '')
      user.build_own_kitchen
      user.save!
      render content_type: 'application/json', json: UserSerializer.new(
        user,
        params: serializer_params
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/user', "Update current user's profile"
    param :display_id, String, allow_blank: true, desc: 'User display id'
    param :name, String, allow_blank: true, desc: 'User name'
    param :birth_date, String, allow_blank: true, desc: 'Birth date'
    param :housework_career, :number, allow_blank: true, desc: 'housework_career'
    param :image, String, allow_blank: true, desc: 'User image url'
    param :description, String, allow_blank: true, desc: 'Description'
    param :website_url, String, allow_blank: true, desc: 'Website url(link)'
    def update
      profile = @current_user.profile
      profile.assign_attributes(user_profile_params)
      @current_user.save!
      render content_type: 'application/json', json: UserSerializer.new(
        @current_user,
        params: serializer_params
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_user_with_code
      @user = User.find_by!(code: params[:code])
    end

    def set_user_with_display_id
      @user = User.joins(:profile).find_by!(user_profiles: { display_id: params[:display_id] })
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

    def serializer_params
      {
        current_user: @current_user
      }
    end
  end
end
