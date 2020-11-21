# frozen_string_literal: true

class User < ApplicationRecord
  include StringUtil

  enum status_id: {
    is_private: 1,
    published: 2,
    official: 3
  }

  before_validation :set_code, on: :create
  before_save :set_default_kitchen

  # NOTE: OAuth完了時に登録するのでメッセージなし.profilesとは別
  # TODO: 更新時用にメッセージ用意
  validates :code, uniqueness: { case_sensitive: true }
  validates :email, presence: true, uniqueness: { case_sensitive: true }

  belongs_to :kitchen, optional: true

  has_one :own_kitchen, foreign_key: 'owner_user_id', class_name: 'Kitchen', inverse_of: :owner, dependent: :nullify
  has_one :profile, class_name: 'UserProfile', dependent: :destroy

  has_many :hot_users, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :followings, foreign_key: 'user_id_from', class_name: 'UserFollow', inverse_of: 'following_user', dependent: :delete_all
  has_many :followers, foreign_key: 'user_id_to', class_name: 'UserFollow', inverse_of: 'follower_user', dependent: :delete_all
  has_many :following_users, through: :followings
  has_many :follower_users, through: :followers
  has_many :recipes, foreign_key: 'author_id', class_name: 'User', inverse_of: 'author', dependent: :nullify
  has_many :recipe_favorite, dependent: :delete_all
  has_many :recipe_keywords, foreign_key: 'author_id', class_name: 'User', inverse_of: 'author', dependent: :nullify
  has_many :recipe_records, foreign_key: 'author_id', class_name: 'User', inverse_of: 'author', dependent: :nullify

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :own_kitchen

  def set_code
    return if self[:code].present?

    klass = self.class
    code = ''
    loop do
      code = klass.generate_random_code(length: 8)
      break unless klass.exists?(code: code)
    end
    self[:code] = code
  end

  def set_default_kitchen
    # TODO: before_saveなはずなのにinsertと別にupdateが入ってしまう。
    self.kitchen = own_kitchen
  end
end
