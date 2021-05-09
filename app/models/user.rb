# frozen_string_literal: true

class User < ApplicationRecord
  include StringUtil

  CODE_REGEX = /[0-9a-zA-Z_.]+/.freeze

  enum status_id: {
    is_private: 1,
    published: 2,
    official: 3
  }

  before_validation :set_code, on: :create
  before_validation :set_default_email, on: :create

  validates :email, presence: true, uniqueness: true

  belongs_to :kitchen, optional: true

  has_one :own_kitchen, foreign_key: 'owner_user_id', class_name: 'Kitchen', inverse_of: :owner, dependent: :nullify
  has_one :profile, class_name: 'UserProfile', dependent: :destroy

  has_many :hot_users, dependent: :delete_all
  has_many :kitchen_joins, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :followings, foreign_key: 'user_id_from', class_name: 'UserFollow', inverse_of: 'following_user', dependent: :delete_all
  has_many :followers, foreign_key: 'user_id_to', class_name: 'UserFollow', inverse_of: 'follower_user', dependent: :delete_all
  has_many :following_users, through: :followings
  has_many :follower_users, through: :followers
  has_many :recipes, foreign_key: 'author_id', class_name: 'Recipe', inverse_of: 'author', dependent: :nullify
  has_many :recipe_favorites, dependent: :delete_all
  has_many :recipe_records, foreign_key: 'author_id', class_name: 'RecipeRecord', inverse_of: 'author', dependent: :nullify

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :own_kitchen

  def to_param
    code
  end

  def set_code
    return if self[:code].present?

    klass = self.class
    self[:code] = loop do
      generated_code = klass.generate_random_code(length: 12)
      break generated_code unless klass.exists?(code: generated_code)
    end
  end

  def set_default_email
    self[:email] = "#{code}@#{Settings.production.base_domain}"
  end

  def my_kitchen?(kitchen)
    self.kitchen == kitchen
  end

  def follow(user)
    user_id_to = user.id
    return false if following_users.exists?(user_id_to) || self == user

    # NOTE: #build の引数に user_id_to を含められない
    uf = followings.build
    uf.user_id_to = user_id_to
    uf.save
  end

  def unfollow(user)
    uf = followings.find_by(user_id_to: user.id)
    return false if uf.blank?

    uf.destroy.present?
  end

  class << self
    def set_kitchen(user: nil, kitchen: nil)
      user.kitchen = kitchen
      user.save!
    end
  end
end
