# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attribute :name do |object|
    object.profile.name
  end
end
