# frozen_string_literal: true

class UserProfile < ApplicationRecord
  include StringUtil
  include GoogleCloudStorageUtil

  before_validation :set_default_display_id, on: :create

  validates :display_id, presence: { message: 'ユーザ名を入力してください' }, uniqueness: { case_sensitive: { message: 'このユーザ名は既に存在しています' } }, format: { with: /\A[0-9a-zA-Z]+\z/, message: '半角英数文字のみが使えます' }, on: %i[create update]
  validates :name, presence: { message: 'ニックネーム入力は必須です' }, length: { in: 2..25, message: 'ニックネーム2~25文字で入力してください' }, on: %i[update]
  validates :housework_career, length: { maximum: 3, message: '本当にそんな生きてるの..?' }, numericality: { only_integer: true, message: '家事歴年数は半角数字で入力してください' }, allow_nil: true, on: %i[update]
  validates :description, length: { maximum: 120, message: '紹介文は%<count>s文字以内で入力してください' }, on: %i[update]
  validates :website_url, length: { maximum: 100, message: '外部リンクは%<count>s文字以内で入力してください' }, on: %i[update]

  belongs_to :user

  def set_default_display_id
    return if self[:display_id].present?

    klass = self.class
    self[:display_id] = loop do
      generated_code = klass.generate_random_code(length: 8)
      break generated_code unless klass.exists?(display_id: generated_code)
    end
  end

  def upload_and_fetch_user_image(encoded_image: nil)
    self[:image] = self.class.upload_and_fetch_image(subject: self[:code], encoded_image: encoded_image, type: :user) || ''
  end
end
