# frozen_string_literal: true

class UserProfile < ApplicationRecord
  validates :name, presence: { message: 'ニックネーム入力は必須です' }, length: { in: 2..25, message: '2~25文字で入力してください' }, on: %i[update]
  validates :housework_career, length: { maximum: 3, message: '本当にそんな生きてるの..?' }, numericality: { only_integer: true, message: '家事歴年数は半角数字で入力してください' }, allow_nil: true, on: %i[update]
  validates :description, length: { maximum: 120, message: '紹介文は%<count>s文字いないで入力してください' }
  validates :website_url, length: { maximum: 100, message: '外部リンクは%<count>s文字以内で入力してください' }, on: %i[update]

  belongs_to :user
end
