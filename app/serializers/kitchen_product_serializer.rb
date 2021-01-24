# frozen_string_literal: true

class KitchenProductSerializer < ApplicationSerializer
  belongs_to :product

  attribute :note, :best_before
end
