# frozen_string_literal: true

class KitchenProductPolicy < ApplicationPolicy
  def update?
    user.my_kitchen?(record.kitchen)
  end

  def destroy?
    user.my_kitchen?(record.kitchen)
  end
end
