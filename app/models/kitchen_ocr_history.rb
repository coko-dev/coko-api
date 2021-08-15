# frozen_string_literal: true

class KitchenOcrHistory < ApplicationRecord
  DAILY_LIMIT = 3

  belongs_to :kitchen

  scope :created_today, -> { where('created_at >= ?', Time.zone.now.beginning_of_day) }

  class << self
    def todays_count(kitchen)
      KitchenOcrHistory.created_today.where(kitchen: kitchen).count
    end
  end
end
