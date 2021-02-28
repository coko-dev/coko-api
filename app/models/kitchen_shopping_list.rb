# frozen_string_literal: true

class KitchenShoppingList < ApplicationRecord
  validates :note, length: { maximum: 64 }, allow_nil: true

  belongs_to :kitchen
  belongs_to :user
  belongs_to :product
end
