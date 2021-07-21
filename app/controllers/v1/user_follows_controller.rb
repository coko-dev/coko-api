# frozen_string_literal: true

module V1
  class UserFollowsController < ApplicationController
    before_action :set_user

    api :GET, '/v1/users/:display_id/followers', 'Show user followers'
    def show_followers
      render content_type: 'application/json', json: UserSerializer.new(
        @user.follower_users,
        params: serializer_params
      ), status: :ok
    end

    api :GET, '/v1/users/:display_id/followings', 'Show user followings'
    def show_followings
      render content_type: 'application/json', json: UserSerializer.new(
        @user.following_users,
        params: serializer_params
      ), status: :ok
    end

    api :POST, '/v1/users/:display_id/follow', 'Follow a user'
    def create
      is_new_record = @current_user.follow(@user)
      render content_type: 'application/json', json: {
        data: { meta: { is_followed: is_new_record } }
      }, status: :ok
    end

    api :DELETE, '/v1/users/:display_id/unfollow', 'Unfollow a user'
    def destroy
      is_deleted = @current_user.unfollow(@user)
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: is_deleted } }
      }, status: :ok
    end

    private

    def set_user
      @user = User.joins(:profile).find_by!(user_profiles: { display_id: params[:display_id] })
    end

    def serializer_params
      {
        current_user: @current_user
      }
    end
  end
end
