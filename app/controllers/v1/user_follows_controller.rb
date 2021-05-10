# frozen_string_literal: true

module V1
  class UserFollowsController < ApplicationController
    before_action :set_user

    api :GET, '/v1/users/:code/followers', 'Show user followers'
    def show_followers
      render content_type: 'application/json', json: UserSerializer.new(
        @user.follower_users
      ), status: :ok
    end

    api :GET, '/v1/users/:code/followings', 'Show user followings'
    def show_followings
      render content_type: 'application/json', json: UserSerializer.new(
        @user.following_users
      ), status: :ok
    end

    api :POST, '/v1/users/:code/follow', 'Follow a user'
    def create
      is_new_record = @current_user.follow(@user)
      render content_type: 'application/json', json: {
        data: { meta: { is_followed: is_new_record } }
      }, status: :ok
    end

    api :DELETE, '/v1/users/:code/unfollow', 'Unfollow a user'
    def destroy
      is_deleted = @current_user.unfollow(@user)
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: is_deleted } }
      }, status: :ok
    end

    private

    def set_user
      @user = User.find_by!(code: params[:code])
    end
  end
end
