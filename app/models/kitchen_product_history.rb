# frozen_string_literal: true

class KitchenProductHistory < ApplicationRecord
  enum status_id: {
    added: 1,
    updated: 2,
    deleted: 3
  }

  belongs_to :kitchen
  belongs_to :user
  belongs_to :product

  delegate :code, to: :user, prefix: true
end
