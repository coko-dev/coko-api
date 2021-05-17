# frozen_string_literal: true

class KitchenProduct < ApplicationRecord
  before_create :set_default_added_on

  belongs_to :kitchen
  belongs_to :product

  def set_default_added_on
    self.added_on ||= Time.zone.today
  end
end
