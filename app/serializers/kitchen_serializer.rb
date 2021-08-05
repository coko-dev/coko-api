# frozen_string_literal: true

class KitchenSerializer < ApplicationSerializer
  attribute :name, :is_subscriber, :owner_user_id, :last_action_at
end
