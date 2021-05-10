# frozen_string_literal: true

class UserFollow < ApplicationRecord
  # NOTE: after_save は削除時にコールバックされない
  after_commit :recount_for_follow

  belongs_to :following_user, foreign_key: 'user_id_from', class_name: 'User', inverse_of: :followings
  belongs_to :follower_user, foreign_key: 'user_id_to', class_name: 'User', inverse_of: :followers

  def recount_for_follow
    following_user.update!(following_count: following_user.following_users.count)
    follower_user.update!(follower_count: follower_user.follower_users.count)
  end
end
