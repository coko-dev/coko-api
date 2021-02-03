# frozen_string_literal: true

class RecipeProduct < ApplicationRecord
  validates :volume, presence: true, length: { maximum: 30 }
  validates :note, length: { maximum: 60 }, allow_blank: true

  belongs_to :recipe
  belongs_to :product
end
