# frozen_string_literal: true

module AuthUtil
  require 'jwt'

  SECRET_KEY_BASE = Rails.application.secrets.secret_key_base

  class << self
    def encode(user_id)
      expires_in = 1.month.from_now.to_i
      preload = {
        user_id: user_id,
        exp: expires_in
      }
      JWT.encode(preload, SECRET_KEY_BASE, 'HS256')
    end

    def decode(encoded_token)
      decoded_jwt = JWT.decode(encoded_token, SECRET_KEY_BASE, true, algorithm: 'HS256')
      decoded_jwt.first
    end
  end
end
