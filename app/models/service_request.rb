# frozen_string_literal: true

class ServiceRequest < AbstractRequest
  enum type_id: {
    request: 1,
    report: 2,
    other: 3
  }
end
