# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  set_id :code

  attribute :is_current_user do |object, params|
    params[:current_user].present? && myself_record?(object, params[:current_user])
  end

  attribute :email, if: proc { |record, params| myself_record?(record, params[:current_user]) }

  attributes :following_count, :follower_count

  attribute :recipe_count do |object|
    object.recipes.count
  end

  attribute :following_count_for_display do |object|
    number_for_display(object.following_count)
  end

  attribute :follower_count_for_display do |object|
    number_for_display(object.follower_count)
  end

  attribute :recipe_count_for_display do |object|
    number_for_display(object.recipes.count)
  end

  attribute :is_followed do |object, params|
    params[:current_user]&.followed?(object)
  end

  attribute :is_following do |object, params|
    params[:current_user]&.following?(object)
  end

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
