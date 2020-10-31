# frozen_string_literal: true

class UserFollow < ApplicationRecord
  belongs_to :following_user, foreign_key: 'user_id_to', class_name: 'User', inverse_of: :followings
  belongs_to :follower_user, foreign_key: 'user_id_from', class_name: 'User', inverse_of: :followers
end
