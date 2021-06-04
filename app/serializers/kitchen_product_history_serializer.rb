# frozen_string_literal: true

class KitchenProductHistorySerializer < ApplicationSerializer
  attributes :status_id, :date

  belongs_to :user
  belongs_to :product
end
