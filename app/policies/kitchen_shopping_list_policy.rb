# frozen_string_literal: true

class KitchenShoppingListPolicy < ApplicationPolicy
  def update?
    user.my_kitchen?(record.kitchen)
  end
end
