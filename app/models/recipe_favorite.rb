# frozen_string_literal: true

class RecipeFavorite < ApplicationRecord
  after_create :increment_favorite_count
  after_destroy :decrement_favorite_count

  belongs_to :recipe
  belongs_to :user

  def increment_favorite_count
    recipe.increment(:favorite_count)
    recipe.save!
  end

  def decrement_favorite_count
    recipe.decrement(:favorite_count)
    recipe.save!
  end
end
