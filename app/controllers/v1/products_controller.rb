# frozen_string_literal: true

module V1
  class ProductsController < ApplicationController
    api :GET, '/v1/products', 'Show products'
    param :receipt_string, String, allow_blank: true, desc: 'Receipt string'
    def index
      receipt_string = params[:receipt_string]
      products =
        if receipt_string.present?
          kitchen = @current_user.kitchen
          raise StandardError, 'Over limits' if KitchenOcrHistory.todays_count(kitchen) > KitchenOcrHistory::DAILY_LIMIT

          prds = Product.find_from_string(receipt_string)
          KitchenOcrHistory.create!(kitchen: kitchen, log: prds.map(&:id))
          prds
        else
          Product.published
        end
      render content_type: 'application/json', json: ProductSerializer.new(
        products
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
