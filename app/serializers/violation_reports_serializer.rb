# frozen_string_literal: true

class ViolationReportsSerializer < ApplicationSerializer
  attributes :reason, :description

  belongs_to :reporting_user, serializer: UserSerializer, id_method_name: :reporting_user_code
  belongs_to :reported_user,  serializer: UserSerializer, id_method_name: :reported_user_code
end
