# frozen_string_literal: true

class ProductRequest < AbstractRequest
  validates :name, presence: true, length: { maximum: 120 }
end
