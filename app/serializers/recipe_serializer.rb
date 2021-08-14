# frozen_string_literal: true

class RecipeSerializer < ApplicationSerializer
  attributes :name, :image, :cooking_time, :servings

  attribute :introduction do |object|
    object.recipe_sections.introduced.first&.body
  end

  attribute :advice do |object|
    object.recipe_sections.adviced.first&.body
  end

  attribute :is_favorite do |object, params|
    object.favorited?(params[:current_user])
  end

  belongs_to :recipe_category
  belongs_to :author, serializer: UserSerializer, id_method_name: :author_code

  has_many :hot_recipe_versions
  has_many :recipe_steps
  has_many :recipe_products
end
