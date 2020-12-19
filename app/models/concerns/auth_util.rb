# frozen_string_literal: true

module AuthUtil
  require 'jwt'

  extend ActiveSupport::Concern

  SECRET_KEY_BASE = Rails.application.secrets.secret_key_base
  JWT_DEFAULT_ALGORITHM = 'HS256'

  module ClassMethods
    def jwt_encode(user_id)
      expires_in = 1.month.from_now.to_i
      preload = {
        user_id: user_id,
        exp: expires_in
      }
      JWT.encode(preload, SECRET_KEY_BASE, algorithm: JWT_DEFAULT_ALGORITHM)
    end

    def jwt_decode(encoded_token)
      decoded_jwt = JWT.decode(encoded_token, SECRET_KEY_BASE, true, algorithm: JWT_DEFAULT_ALGORITHM)
      decoded_jwt.first.symbolize_keys
    end
  end
end
