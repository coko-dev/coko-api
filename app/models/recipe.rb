# frozen_string_literal: true

class Recipe < ApplicationRecord
  enum status_id: {
    published: 1,
    hidden: 2
  }

  validates :name, presence: true
  # TODO: validates :image
  validates :cooking_time, presence: true, length: { maximum: 3 }

  belongs_to :author, class_name: 'User', inverse_of: 'recipes'
  belongs_to :recipe_category

  has_many :hot_recipes, dependent: :delete_all
  has_many :hot_recipe_versions, through: :hot_recipes
  has_many :recipe_favorites, dependent: :delete_all
  has_many :recipe_keyword_lists, dependent: :delete_all
  has_many :recipe_keywords, through: :recipe_keyword_lists
  has_many :recipe_products, dependent: :delete_all
  has_many :products, through: :recipe_products
  has_many :recipe_records, dependent: :delete_all
  has_many :recipe_sections, dependent: :delete_all
  has_many :recipe_steps, dependent: :delete_all

  def build_or_update_each_sections(introduction:, advice:)
    RecipeSection.status_ids.keys.zip([introduction, advice]) do |st, body|
      next if body.blank?

      rc = recipe_sections.find_by(status_id: st)
      if rc.present?
        rc.update!(body: body)
      else
        recipe_sections.build(status_id: st, body: body)
      end
    end
  end

  def build_each_keywords(keyword_ids)
    return if keyword_ids.blank?

    keyword_ids.uniq!

    keyword_ids.each do |keyword_id|
      kw = RecipeKeyword.where(is_blacked: false).find(keyword_id)
      recipe_keyword_lists.build(recipe_keyword: kw)
    end
  end

  def build_each_steps(step_params)
    return if step_params.blank?

    step_params.each.with_index(1) do |param, idx|
      recipe_steps.build(sort_order: idx, body: param[:body], image: param[:image])
    end
  end

  def build_each_recipe_products(recipe_product_params)
    return if recipe_product_params.blank?

    recipe_product_params.each do |param|
      prd = Product.find(param[:product_id])
      recipe_products.build(product: prd, volume: param[:volume], note: param[:note])
    end
  end
end
