# frozen_string_literal: true

class RecipeSerializer < ApplicationSerializer
  attributes :name, :image, :cooking_time

  attribute :introduction do |object|
    object.recipe_sections.introduced.first.body
  end

  attribute :advice do |object|
    object.recipe_sections.adviced.first.body
  end

  belongs_to :recipe_category
  belongs_to :author, serializer: UserSerializer
end
