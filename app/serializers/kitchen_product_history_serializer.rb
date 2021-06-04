# frozen_string_literal: true

class KitchenProductHistorySerializer < ApplicationSerializer
  attributes :status_id, :date

  belongs_to :user, id_method_name: :user_code
  belongs_to :product
end
