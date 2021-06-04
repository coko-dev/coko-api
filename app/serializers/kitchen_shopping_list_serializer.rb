# frozen_string_literal: true

class KitchenShoppingListSerializer < ApplicationSerializer
  attributes :note

  belongs_to :product
  belongs_to :user, id_method_name: :user_code
end
