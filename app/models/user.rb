# frozen_string_literal: true

class User < ApplicationRecord
  has_one :user_profile, dependent: :destroy

  has_many :followings, foreign_key: 'user_id_from', class_name: 'UserFollow', inverse_of: 'following_user', dependent: :delete_all
  has_many :followers, foreign_key: 'user_id_to', class_name: 'UserFollow', inverse_of: 'follower_user', dependent: :delete_all
  has_many :following_users, through: :followings
  has_many :follower_users, through: :followers
end
