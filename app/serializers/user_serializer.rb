# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  set_id :to_param

  attribute :email, if: proc { |record, params| myself_record?(record, params[:current_user]) }

  attributes :following_count, :follower_count

  attribute :display_id do |object|
    object.profile.display_id
  end

  attribute :name do |object|
    object.profile.name
  end

  attribute :description do |object|
    object.profile.description
  end

  attribute :housework_career do |object|
    object.profile.housework_career
  end

  attribute :image do |object|
    object.profile.image
  end

  attribute :website_url do |object|
    object.profile.website_url
  end
end
