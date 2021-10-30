# frozen_string_literal: true

class KitchenSerializer < ApplicationSerializer
  # TODO: last_action_at, todays_ocr_count は自身のキッチンの場合のみ表示
  attribute :name, :is_subscriber, :owner_user_id, :last_action_at

  attribute :todays_ocr_count do |object|
    object.todays_ocr_count
  end
end
