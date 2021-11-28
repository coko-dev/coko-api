# frozen_string_literal: true

class KitchenProduct < ApplicationRecord
  MAXIMUM_NUMBER = 30

  before_create :set_default_added_on

  belongs_to :kitchen
  belongs_to :product

  def set_default_added_on
    self.added_on ||= Time.zone.today
  end

  class << self
    def over_num_limit?(kitchen, add_num: nil)
      add_num ||= 0
      kitchen.kitchen_products.count + add_num > MAXIMUM_NUMBER
    end
  end
end
