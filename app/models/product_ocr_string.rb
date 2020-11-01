# frozen_string_literal: true

class ProductOcrString < ApplicationRecord
  belongs_to :kitchen
  belongs_to :product
end
