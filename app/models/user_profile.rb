# frozen_string_literal: true

class UserProfile < ApplicationRecord
  include GoogleCloudStorageUtil

  validates :name, presence: { message: 'ニックネーム入力は必須です' }, length: { in: 2..25, message: '2~25文字で入力してください' }, on: %i[update]
  validates :housework_career, length: { maximum: 3, message: '本当にそんな生きてるの..?' }, numericality: { only_integer: true, message: '家事歴年数は半角数字で入力してください' }, allow_nil: true, on: %i[update]
  validates :description, length: { maximum: 120, message: '紹介文は%<count>s文字以内で入力してください' }, on: %i[update]
  validates :website_url, length: { maximum: 100, message: '外部リンクは%<count>s文字以内で入力してください' }, on: %i[update]

  belongs_to :user

  class << self
    def upload_and_fetch_image(user_id: nil, image: nil)
      bin = Base64.decode64(image)
      bucket = fetch_bucket
      file_name = "#{user_id}-#{Time.zone.now}.png"
      path = "#{Rails.root}/tmp/#{file_name}"
      gcs_image = nil
      File.open(path, 'wb+') do |file|
        file.write(bin)
        gcs_image = upload_image(bucket: bucket, image: file, file_name: file_name)
      end
      File.delete(path)
      gcs_image.signed_url
    end
  end
end
