# frozen_string_literal: true

class KitchenShoppingList < ApplicationRecord
  MAXIMUM_NUMBER = 6
  
  validates :note, length: { maximum: 32 }, allow_nil: true

  belongs_to :kitchen
  belongs_to :user
  belongs_to :product

  delegate :code, to: :user, prefix: true

  class << self
    def over_num_limit?(kitchen, add_num: nil)
      add_num ||= 0
      kitchen.kitchen_shopping_lists.count + add_num > MAXIMUM_NUMBER
    end
  end
end
