# frozen_string_literal: true

class ProductRequestSerializer < ApplicationSerializer
  attributes :name, :body, :status_id, :is_required_notice

  belongs_to :user, id_method_name: :user_code
end
