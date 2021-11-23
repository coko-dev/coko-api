# frozen_string_literal: true

class KitchenSerializer < ApplicationSerializer
  attributes :name, :owner_user_id

  attributes :is_subscriber, :last_action_at, :todays_ocr_count, if: proc { |record, params| params[:current_user]&.my_kitchen?(record) }

  has_many :users, id_method_name: :code do |object|
    object.users
  end
end
