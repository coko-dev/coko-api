# frozen_string_literal: true

class RecipeSection < ApplicationRecord
  validates :body, presence: true, length: { maximum: 400 }

  enum status_id: {
    introduced: 1,
    adviced: 2
  }

  belongs_to :recipe
end
