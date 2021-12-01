# frozen_string_literal: true

class KitchenSerializer < ApplicationSerializer
  attributes :name

  attributes :is_subscriber, :last_action_at, :todays_ocr_count, if: proc { |record, params| params[:current_user]&.my_kitchen?(record) }

  belongs_to :owner, serializer: UserSerializer, id_method_name: :owner_code
  has_many :users, id_method_name: :code, &:users
end
