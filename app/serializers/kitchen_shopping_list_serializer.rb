# frozen_string_literal: true

class KitchenShoppingListSerializer < ApplicationSerializer
  attributes :note

  belongs_to :product
  belongs_to :user
end
