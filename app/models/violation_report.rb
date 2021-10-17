# frozen_string_literal: true

class ViolationReport < ApplicationRecord
  validates :reason, length: { maximum: 120 }
  validates :description, length: { maximum: 120 }

  belongs_to :reporting_user, class_name: 'User', inverse_of: :reportings
  belongs_to :reported_user,  class_name: 'User', inverse_of: :reporteds

  delegate :code, to: :reporting_user, prefix: true
  delegate :code, to: :reported_user,  prefix: true
end
