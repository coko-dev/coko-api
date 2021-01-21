# frozen_string_literal: true

class KitchenJoin < ApplicationRecord
  include StringUtil

  CODE_MAXIMUM = 99_999

  # NOTE: Disable the default 'open' method.
  class << self; undef :open; end

  enum status_id: {
    open: 1,
    closed: 2
  }

  before_validation :set_code, on: :create
  before_create :close_duplicated

  validates :kitchen_id, presence: true
  validates :code, presence: true, length: { is: 6 }

  belongs_to :kitchen
  belongs_to :user

  def set_code
    return if self[:code].present?

    klass = self.class
    self[:code] = loop do
      generated_code = klass.generate_random_number(length: 6)
      break generated_code unless generated_code < CODE_MAXIMUM || klass.open.exists?(code: generated_code)
    end
  end

  def close_duplicated
    kitchen_joins = kitchen.kitchen_joins.open
    kitchen_joins.each(&:closed!)
  end
end
