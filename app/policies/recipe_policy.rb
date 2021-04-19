# frozen_string_literal: true

class RecipePolicy < ApplicationPolicy
  def update?
    record.author == user
  end
end
