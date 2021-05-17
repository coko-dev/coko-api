# frozen_string_literal: true

class KitchenProductSerializer < ApplicationSerializer
  attribute :note, :added_on, :best_before

  belongs_to :product
end
