# frozen_string_literal: true

class Product < ApplicationRecord
  enum status_id: {
    published: 1,
    hidden: 2
  }

  belongs_to :product_category
  belongs_to :author, class_name: 'AdminUser', inverse_of: 'products'

  has_many :kitchen_products, dependent: :delete_all
  has_many :kitchen_product_histories, dependent: :delete_all
  has_many :kitchen_shopping_lists, dependent: :delete_all
  has_many :product_ocr_strings, dependent: :delete_all
  has_many :recipe_products, dependent: :delete_all
  has_many :recipes, through: :recipe_products

  validates :name, presence: true, length: { maximum: 32 }, on: %i[create update]
  validates :name_hira, length: { maximum: 32 }
  validates :product_category_id, presence: true, on: %i[create update]

  def upload_and_fetch_product_image(subject: nil, encoded_image: nil)
    self[:image] = self.class.upload_and_fetch_image(subject: subject, encoded_image: encoded_image, type: :product) || ''
  end

  class << self
    def find_from_string(body)
      ocr_strs = ProductOcrString.official.order('CHAR_LENGTH(ocr_string) DESC')
      prd_ids = []
      ocr_strs.each do |ocr_str|
        str = ocr_str.ocr_string
        next unless body.include?(str)

        prd_ids << ocr_str.product_id
        body.gsub!(str, ' ')
      end
      Product.find(prd_ids)
    end
  end
end
