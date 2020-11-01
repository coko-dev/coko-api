# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :kitchen

  has_one :own_kitchen, foreign_key: 'owner_user_id', class_name: 'Kitchen', inverse_of: :owner, dependent: :nullify
  has_one :profile, class_name: 'UserProfile', dependent: :destroy

  has_many :hot_users, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :followings, foreign_key: 'user_id_from', class_name: 'UserFollow', inverse_of: 'following_user', dependent: :delete_all
  has_many :followers, foreign_key: 'user_id_to', class_name: 'UserFollow', inverse_of: 'follower_user', dependent: :delete_all
  has_many :following_users, through: :followings
  has_many :follower_users, through: :followers
end
