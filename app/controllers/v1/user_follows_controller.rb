# frozen_string_literal: true

module V1
  class UserFollowsController < ApplicationController
    before_action :set_user, except: %i[show_blockings show_mutings]

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

    api :GET, '/v1/users/blockings', 'Show user blockings'
    def show_blockings
      render content_type: 'application/json', json: UserSerializer.new(
        @current_user.blocking_users,
        params: serializer_params
      ), status: :ok
    end

    api :GET, '/v1/users/mutings', 'Show user mutings'
    def show_mutings
      render content_type: 'application/json', json: UserSerializer.new(
        @current_user.muting_users,
        params: serializer_params
      ), status: :ok
    end

    api :POST, '/v1/users/:display_id/follow', 'Follow a user'
    def create
      authorize :application, :account_based?

      render content_type: 'application/json', json: {
        data: { meta: { is_followed: @current_user.follow(@user) } }
      }, status: :ok
    end

    api :DELETE, '/v1/users/:display_id/unfollow', 'Unfollow a user'
    def destroy
      render content_type: 'application/json', json: {
        data: { meta: { is_deleted: @current_user.unfollow(@user) } }
      }, status: :ok
    end

    api :POST, '/v1/users/:display_id/block', 'Block a user'
    def block
      authorize :application, :account_based?

      render content_type: 'application/json', json: {
        data: { meta: { is_blocked: @current_user.block(@user) } }
      }, status: :ok
    end

    api :DELETE, '/v1/users/:display_id/unblock', 'Unblock a user'
    def unblock
      render content_type: 'application/json', json: {
        data: { meta: { is_unblocked: @current_user.unblock(@user) } }
      }, status: :ok
    end

    api :POST, '/v1/users/:display_id/mute', 'Mute a user'
    def mute
      authorize :application, :account_based?

      render content_type: 'application/json', json: {
        data: { meta: { is_muted: @current_user.mute(@user) } }
      }, status: :ok
    end

    api :DELETE, '/v1/users/:display_id/unmute', 'Unmute a user'
    def unmute
      render content_type: 'application/json', json: {
        data: { meta: { is_unmuted: @current_user.unmute(@user) } }
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
