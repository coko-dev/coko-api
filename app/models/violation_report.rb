# frozen_string_literal: true

class ViolationReport < ApplicationRecord
  validates :reason, length: { maximum: 120 }
  validates :description, length: { maximum: 120 }

  belongs_to :reporting_user, foreign_key: 'reporting_user_id', class_name: 'User', inverse_of: :reportings
  belongs_to :reported_user, foreign_key: 'reported_user_id', class_name: 'User', inverse_of: :reporteds
end
