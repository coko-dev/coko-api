# frozen_string_literal: true

module V1
  class ViolationReportsController < ApplicationController
    api :POST, '/v1/violation_reports', 'Report user violations'
    param :user_id, String, required: true, desc: 'User ID reported as a violation'
    param :reason, String, required: true, desc: 'Reason for reporting'
    param :description, String, allow_blank: true, desc: 'Details of reason for reporting'
    def create
      reported_user = User.find_by!(code: params[:user_id])
      ViolationReport.create!(reporting_user_id: @current_user.id, reported_user_id: reported_user.id, reason: params[:reason], description: params[:description])
    end
  end
end
