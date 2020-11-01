# frozen_string_literal: true

class RecipeFavorite < ApplicationRecord
  belongs_to :recipe
  belongs_to :user
end
