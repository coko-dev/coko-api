# frozen_string_literal: true

class KitchenJoin < ApplicationRecord
  include StringUtil

  enum status_id: {
    open: 1,
    closed: 2
  }

  before_validation :set_code, on: :create
  before_create :close_duplicated

  validates :kitchen_id, presence: true
  validates :code, presence: true, length: { is: 6 }

  belongs_to :kitchen

  def set_code
    return if self[:code].present?

    klass = self.class
    minimum = 99_999
    generated_code = 0
    loop do
      generated_code = klass.generate_random_number(length: 6)
      break unless generated_code < minimum || klass.open.exists?(code: generated_code)
    end
    self[:code] = generated_code
  end

  def close_duplicated
    kitchen_joins = kitchen.kitchen_joins.open
    kitchen_joins.each(&:closed!)
  end
end
