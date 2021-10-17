# frozen_string_literal: true

module Admin
  class ViolationReportsController < ApplicationController
    api :GET, '/admin/violation_reports', 'Show all user violation reports'
    def index
      render content_type: 'application/json', json: ViolationReportsSerializer.new(
        ViolationReport.all
      ), status: :ok
    end
  end
end
