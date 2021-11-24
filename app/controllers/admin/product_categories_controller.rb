# frozen_string_literal: true

module Admin
  class ProductCategoriesController < ApplicationController
    before_action :set_product_category, only: %i[update]

    api :GET, '/admin/product_categories', 'Show all product categories'
    def index
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        ProductCategory.all
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/admin/product_categories', 'Create product category'
    param :name, String, required: true, desc: 'Category name for display'
    param :name_slug, String, required: true, desc: 'Category name slug'
    param :parent_category_id, String, allow_blank: true, desc: "Parent category's key"
    def create
      product_category = ProductCategory.new(product_category_params)
      parent_category_id = params[:parent_category_id]
      product_category.parent_category = ProductCategory.find(parent_category_id) if parent_category_id.present?
      product_category.save!
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        product_category
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/admin/product_categories', 'Update product category'
    param :name, String, allow_blank: true, desc: 'Category name for display'
    param :name_slug, String, allow_blank: true, desc: 'Category name slug'
    param :parent_category_id, String, allow_blank: true, desc: "Parent category's key"
    def update
      @product_category.assign_attributes(product_category_params)
      parent_category_id = params[:parent_category_id]
      @product_category.parent_category = ProductCategory.find(parent_category_id) if parent_category_id.present?
      @product_category.save!
      render content_type: 'application/json', json: ProductCategorySerializer.new(
        @product_category
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_product_category
      @product_category = ProductCategory.find(params[:id])
    end

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
