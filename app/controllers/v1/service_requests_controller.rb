# frozen_string_literal: true

module V1
  class ServiceRequestsController < ApplicationController
    api :POST, '/v1/service_requests', 'Create service request'
    param :body, String, required: true, desc: 'Discription for request'
    param :type, %w[request report other], required: true, desc: 'Request type'
    param :is_required_notice, [true, false], allow_blank: true, desc: 'Does the user need notification?. Default: false'
    def create
      service_request = ServiceRequest.new(user: @current_user, type_id: ServiceRequest.type_ids[params[:type]], status_id: :pending)
      service_request.assign_attributes(service_request_params)
      service_request.save!
      render content_type: 'application/json', json: ServiceRequestSerializer.new(
        service_request
      )
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def service_request_params
      params.permit(
        %i[
          body
          is_required_notice
        ]
      )
    end
  end
end
