# frozen_string_literal: true

class RecipeRecordSerializer < ApplicationSerializer
  attributes :body

  attribute :recipe_record_images do |object|
    object.recipe_record_images.map(&:image)
  end

  belongs_to :recipe
  belongs_to :author, serializer: UserSerializer, id_method_name: :author_code
end
