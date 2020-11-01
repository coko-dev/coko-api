# frozen_string_literal: true

class KitchenProduct < ApplicationRecord
  belongs_to :kitchen
  belongs_to :product
end
