# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  set_id :to_param

  attribute :email, if: proc { |record, params| myself_record?(record, params[:current_user]) }

  attribute :display_id do |object|
    object.profile.display_id
  end

  attribute :name do |object|
    object.profile.name
  end

  attribute :description do |object|
    object.profile.description
  end
end
