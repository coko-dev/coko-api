# frozen_string_literal: true

class AbstractRequest < ApplicationRecord
  self.abstract_class = true

  enum status_id: {
    pending: 1,
    done: 2
  }

  belongs_to :user

  delegate :code, to: :user, prefix: true
end
