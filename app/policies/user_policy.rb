# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # TESTING
  def update?
    record == user
  end
end
