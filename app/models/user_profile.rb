# frozen_string_literal: true

class UserProfile < ApplicationRecord
  include StringUtil
  include GoogleCloudStorageUtil

  DEFAULT_NICKNAME = 'ニックネーム'

  before_validation :set_default_display_id, on: :create
  before_validation :set_default_name, on: :create

  validates :display_id, presence: true, uniqueness: { case_sensitive: true }, format: { with: /\A[0-9a-zA-Z]+\z/, message: '半角英数文字のみが使えます' }, on: %i[create update]
  validates :name, presence: true, length: { in: 1..25 }, on: %i[update]
  validates :housework_career, length: { maximum: 3 }, numericality: { only_integer: true }, allow_nil: true, on: %i[update]
  validates :description, length: { maximum: 120 }, on: %i[update]
  validates :website_url, length: { maximum: 100 }, on: %i[update]

  # NOTE: Enable 'autosave' option to save at the same time as 'User'.
  belongs_to :user, autosave: true

  def set_default_display_id
    return if self[:display_id].present?

    klass = self.class
    self[:display_id] = loop do
      generated_code = klass.generate_random_code(length: 8)
      break generated_code unless klass.exists?(display_id: generated_code)
    end
  end

  def set_default_name
    return if self[:name].present?

    self[:name] = DEFAULT_NICKNAME
  end

  def upload_and_fetch_user_image(encoded_image: nil)
    self[:image] = self.class.upload_and_fetch_image(subject: self[:code], encoded_image: encoded_image, type: :user) || ''
  end
end
