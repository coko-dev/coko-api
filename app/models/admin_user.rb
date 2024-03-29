# frozen_string_literal: true

class AdminUser < ApplicationRecord
  include StringUtil

  CODE_MINIMUM = 100_000

  has_secure_password

  validates :email, presence: { message: 'メールアドレスを入力してください' }, uniqueness: { message: 'このメールアドレスは既に登録されています' }, on: :create
  validates :password, presence: { message: 'パスワードを入力してください' }, format: { with: /\A[0-9a-zA-Z]+\z/, message: '半角英数文字のみが使えます' }, confirmation: { message: '確認用のパスワードと一致しません' }, on: %i[create update]
  validates :password_confirmation, presence: { message: '確認用のパスワードを入力してください' }, on: %i[create update]

  enum role_id: {
    read: 1,
    write: 2,
    admin: 3
  }

  # TODO: role_id
  # TODO: last_sign_in_at

  has_many :products, foreign_key: 'author_id', class_name: 'Product', inverse_of: 'author', dependent: :nullify
  has_many :recipe_keywords, foreign_key: 'author_id', class_name: 'RecipeKeyword', inverse_of: 'author', dependent: :nullify

  class << self
    def generate_pass_code
      loop do
        generated_code = generate_random_number(length: 6)
        break generated_code if generated_code >= CODE_MINIMUM
      end
    end
  end
end
