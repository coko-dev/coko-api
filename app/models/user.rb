# frozen_string_literal: true

class User < ApplicationRecord
  include StringUtil

  CODE_REGEX = /[0-9a-zA-Z_.]+/.freeze

  enum status_id: {
    is_private: 1,
    published: 2,
    official: 3
  }

  has_secure_password

  before_validation :set_code, on: :create
  before_validation :set_default_email, on: :create

  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true, on: %i[create update]

  belongs_to :kitchen, optional: true

  has_one :own_kitchen, foreign_key: 'owner_user_id', class_name: 'Kitchen', inverse_of: :owner, dependent: :nullify
  has_one :profile, class_name: 'UserProfile', dependent: :destroy

  has_many :hot_users, dependent: :delete_all
  has_many :kitchen_joins, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :followings, foreign_key: 'user_id_from', class_name: 'UserFollow', inverse_of: 'following_user', dependent: :delete_all
  has_many :followers,  foreign_key: 'user_id_to',   class_name: 'UserFollow', inverse_of: 'follower_user',  dependent: :delete_all
  has_many :following_users, -> { merge(UserFollow.followed) }, through: :followings, source: :follower_user
  has_many :follower_users,  -> { merge(UserFollow.followed) }, through: :followers,  source: :following_user
  has_many :blocking_users, -> { merge(UserFollow.blocked) }, through: :followings, source: :follower_user
  has_many :blocker_users,  -> { merge(UserFollow.blocked) }, through: :followers,  source: :following_user
  has_many :muting_users, -> { merge(UserFollow.muted) }, through: :followings, source: :follower_user
  has_many :muted_users,  -> { merge(UserFollow.muted) }, through: :followers,  source: :following_user
  has_many :all_following_users, through: :followings, source: :follower_user
  has_many :all_follower_users,  through: :followers,  source: :following_user
  has_many :recipes, foreign_key: 'author_id', class_name: 'Recipe', inverse_of: 'author', dependent: :nullify
  has_many :recipe_favorites, dependent: :delete_all
  has_many :recipe_records, foreign_key: 'author_id', class_name: 'RecipeRecord', inverse_of: 'author', dependent: :nullify
  has_many :reportings, foreign_key: 'reporting_user_id', class_name: 'ViolationReport', inverse_of: 'reporting_user', dependent: :delete_all
  has_many :reporteds,  foreign_key: 'reported_user_id',  class_name: 'ViolationReport', inverse_of: 'reported_user',  dependent: :delete_all
  has_many :reporting_users, through: :reportings, source: :reporting_user
  has_many :reported_users,  through: :reporteds,  source: :reported_user

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :own_kitchen

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

  def myself?(current_user)
    current_user.present? && self == current_user
  end

  def my_kitchen?(kitchen)
    self.kitchen == kitchen
  end

  def follow(user)
    uf = followings.find_or_initialize_by(user_id_to: user.id, status_id: :followed)
    uf.new_record? && uf.save
  end

  def unfollow(user)
    uf = followings.find_by(user_id_to: user.id, status_id: :followed)
    return false if uf.blank?

    uf.destroy.present?
  end

  def followed?(user)
    return false if myself?(user)

    follower_users.exists?(id: user.id)
  end

  def following?(user)
    return false if myself?(user)

    following_users.exists?(id: user.id)
  end

  def block(user)
    uf = followings.find_or_initialize_by(user_id_to: user.id, status_id: :blocked)
    uf.new_record? && uf.save
  end

  def unblock(user)
    uf = followings.find_by(user_id_to: user.id, status_id: :blocked)
    return false if uf.blank?

    uf.destroy.present?
  end

  def mute(user)
    uf = followings.find_or_initialize_by(user_id_to: user.id, status_id: :muted)
    uf.new_record? && uf.save
  end

  def unmute(user)
    uf = followings.find_by(user_id_to: user.id, status_id: :muted)
    return false if uf.blank?

    uf.destroy.present?
  end

  # NOTE: ブロックしている、ブロックされている、ミュートしているユーザの id
  # :reek:DuplicateMethodCall { exclude: [filter_user_ids] }
  def filter_user_ids
    uf_status_ids = UserFollow.status_ids
    UserFollow
      .where(<<~SQL, id, id, uf_status_ids[:blocked], id, uf_status_ids[:muted])
        ((user_id_to = ? OR user_id_from = ?) AND user_follows.status_id = ? )
        OR (user_id_from = ? AND user_follows.status_id = ? )
      SQL
      .select(:user_id_from, :user_id_to)
      .map { |uf| uf.user_id_to == id ? uf.user_id_from : uf.user_id_to }.uniq
  end

  class << self
    def set_kitchen(user: nil, kitchen: nil)
      current_kitchen = user.kitchen
      raise StandardError, "You can't leave subscribed kitchen" if current_kitchen&.is_subscriber

      ApplicationRecord.transaction do
        # NOTE: 離れるキッチンのオーナーだった場合、ユーザ作成日が古いユーザを自動的にオーナーに割り振る。ユーザがいない場合 nil
        if current_kitchen&.owner = user
          next_owner = current_kitchen.users.where.not(id: user.id).order(created_at: :desc).first
          current_kitchen.update!(owner: next_owner)
        end
        user.update!(kitchen: kitchen)
      end
    end
  end
end
