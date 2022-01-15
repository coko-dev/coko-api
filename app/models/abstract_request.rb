# frozen_string_literal: true

class AbstractRequest < ApplicationRecord
  self.abstract_class = true

  enum status_id: {
    pending: 1,
    done: 2
  }
  
  validates :body, presence: true, length: { maximum: 400 }

  belongs_to :user, optional: true
end
