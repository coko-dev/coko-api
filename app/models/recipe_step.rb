# frozen_string_literal: true

class RecipeStep < ApplicationRecord
  validates :body, presence: true, length: { maximum: 400 }
  # TODO: validates :image ... , allow_blank: true

  belongs_to :recipe
end
