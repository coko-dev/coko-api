# frozen_string_literal: true

class ServiceRequestSerializer < ApplicationSerializer
  attributes :body, :type_id, :status_id, :is_required_notice

  belongs_to :user, id_method_name: :user_code
end
