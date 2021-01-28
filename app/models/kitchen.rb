# frozen_string_literal: true

class Kitchen < ApplicationRecord
  before_create :touch_last_action_at
  after_create :set_default_kitchen_for_user

  belongs_to :owner, foreign_key: 'owner_user_id', class_name: 'User', inverse_of: :own_kitchen

  has_many :kitchen_joins, dependent: :delete_all
  has_many :kitchen_ocr_histories, dependent: :delete_all
  has_many :kitchen_products, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :ktichen_shopping_lists, dependent: :delete_all
  has_many :product_ocr_strings, dependent: :delete_all
  has_many :users, dependent: :nullify

  accepts_nested_attributes_for :kitchen_product_histories

  def touch_last_action_at
    self.last_action_at = Time.zone.now
  end

  def set_default_kitchen_for_user
    User.set_kitchen(user: owner, kitchen: self)
  end
end
