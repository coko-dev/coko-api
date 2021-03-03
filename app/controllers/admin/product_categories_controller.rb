# frozen_string_literal: true

module Admin
  class ProductCategoriesController < ApplicationController
    api :GET, '/admin/product_categories', 'Show all product categories'
    def index
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        ProductCategory.all
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/admin/product_categories', 'Create product category'
    param :name, String, required: true, desc: 'Category name for display'
    param :name_slug, String, required: true, desc: 'Category name slug'
    param :parent_category_id, :number, desc: "Parent category's key"
    def create
      product_category = ProductCategory.new(product_category_params)
      parent_category_id = params[:parent_category_id]
      product_category.parent_category = ProductCategory.find(parent_category_id) if parent_category_id.present?
      product_category.save!
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        product_category
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def product_category_params
      params.permit(
        %i[
          name
          name_slug
        ]
      )
    end
  end
end
