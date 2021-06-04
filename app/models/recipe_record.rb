# frozen_string_literal: true

class RecipeRecord < ApplicationRecord
  validates :body, presence: true, length: { maximum: 400 }

  belongs_to :author, class_name: 'User', inverse_of: 'recipe_records'
  belongs_to :recipe

  has_many :recipe_record_images, dependent: :delete_all

  delegate :code, to: :author, prefix: true

  def build_each_images(image_params)
    return if image_params.blank?

    image_params.each do |param|
      recipe_record_images.build(image: param[:image])
    end
  end
end
