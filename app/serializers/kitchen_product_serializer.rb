# frozen_string_literal: true

class KitchenProductSerializer < ApplicationSerializer
  attribute :note, :best_before

  belongs_to :product
end
