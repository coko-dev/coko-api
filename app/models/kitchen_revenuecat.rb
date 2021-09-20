# frozen_string_literal: true

class KitchenRevenuecat < ApplicationRecord
  belongs_to :kitchen, optional: true
end
