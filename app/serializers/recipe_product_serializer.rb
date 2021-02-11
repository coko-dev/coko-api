# frozen_string_literal: true

class RecipeProductSerializer < ApplicationSerializer
  attributes :note, :volume, :note

  belongs_to :product
end
