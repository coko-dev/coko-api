# frozen_string_literal: true

class Kitchen < ApplicationRecord
  before_create :touch_last_action_at
  after_create :set_default_kitchen_for_user

  enum status_id: {
    is_private: 1,
    published: 2,
    official: 3
  }

  validates :name, presence: true, length: { in: 2..25 }

  belongs_to :owner, foreign_key: 'owner_user_id', class_name: 'User', inverse_of: :own_kitchen

  has_many :kitchen_joins, dependent: :delete_all
  has_many :kitchen_ocr_histories, dependent: :delete_all
  has_many :kitchen_products, dependent: :delete_all
  has_many :products, through: :kitchen_products
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :product_ocr_strings, dependent: :delete_all
  has_many :users, dependent: :nullify

  accepts_nested_attributes_for :kitchen_product_histories

  def touch_last_action_at
    self.last_action_at = Time.zone.now
  end

  def set_default_kitchen_for_user
    User.set_kitchen(user: owner, kitchen: self)
  end

  def touch_with_history_build(user:, product:, status_id:)
    touch_last_action_at
    kitchen_product_histories.build(user: user, product: product, date: Time.zone.today, status_id: status_id)
  end

  def todays_ocr_count
    KitchenOcrHistory.todays_count(self)
  end
end
