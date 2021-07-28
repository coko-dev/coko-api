# frozen_string_literal: true

class Recipe < ApplicationRecord
  enum status_id: {
    published: 1,
    hidden: 2
  }

  validates :name, presence: true
  # TODO: validates :image
  validates :cooking_time, presence: true, length: { maximum: 3 }
  validates :servings, presence: true, length: { maximum: 2 }

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

  delegate :code, to: :author, prefix: true

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

  class << self
    def narrow_down_recipes(params, current_user)
      product_ids = current_user.kitchen.products.distinct.ids
      recipes = Recipe.joins(:recipe_products).group(:id).having('COUNT(recipe_products.product_id IN (?) OR NULL) = COUNT(recipe_products.product_id)', product_ids) if params[:can_be_made].present?

      recipes = recipes.joins(:hot_recipe_versions).where(hot_recipe_versions: { status_id: 'enabled' }) if params[:hot_recipes].present?

      category_id = params[:recipe_category_id]
      category = RecipeCategory.find_by(id: category_id)
      recipes = recipes.where(recipe_category: category) if category_id.present?

      user_id = params[:user_id]
      author = User.find_by(code: user_id)
      recipes = recipes.where(author: author) if user_id.present?

      servings = params[:servings]
      recipes = recipes.where(servings: servings) if servings.present?

      cooking_time_within = params[:cooking_time_within]
      recipes = recipes.where(cooking_time: 1..cooking_time_within) if cooking_time_within.present?

      recipes = recipes.where(id: RecipeProduct.group(:recipe_id).having('count(*) < ?', 5).select(:recipe_id)) if params[:with_few_products]
      recipes
    end

    def can_be_made_recipes(kitchen)
      product_ids = kitchen.products.distinct.ids
      Recipe.joins(:recipe_products).group(:id).having('COUNT(recipe_products.product_id IN (?) OR NULL) = COUNT(recipe_products.product_id)', product_ids)
    end
  end
end
