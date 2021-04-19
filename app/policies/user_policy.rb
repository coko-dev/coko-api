# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    record == user
  end
end
