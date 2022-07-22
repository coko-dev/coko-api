# frozen_string_literal: true

class UserTrash < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :display_id, presence: true, uniqueness: true
  validates :payload, presence: true
end
