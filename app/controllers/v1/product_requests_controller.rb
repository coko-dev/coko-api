# frozen_string_literal: true

module V1
  class ProductRequestsController < ApplicationController
    api :POST, '/v1/product_requests', 'Create product request'
    param :name, String, allow_blank: true, desc: 'Requested product name'
    param :body, String, required: true, desc: "Discription for request"
    param :is_required_notice, [true, false], allow_blank: true, desc: 'Does the user need notification?. Default: false'
    def create
      product_request = ProductRequest.new(user: @current_user, status_id: :pending)
      product_request.assign_attributes(product_request_params)
      product_request.save!
      render content_type: 'application/json', json: ProductRequestSerializer.new(
        product_request
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def product_request_params
      params.permit(
        %i[
          name
          body
          is_required_notice
        ]
      )
    end
  end
end
