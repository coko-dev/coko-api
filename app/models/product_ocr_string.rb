# frozen_string_literal: true

class ProductOcrString < ApplicationRecord
  belongs_to :kitchen, optional: true
  belongs_to :product

  scope :official, -> { where(kitchen: nil) }
end
