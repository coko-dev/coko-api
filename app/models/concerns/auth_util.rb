# frozen_string_literal: true

module AuthUtil
  require 'jwt'

  extend ActiveSupport::Concern

  SECRET_KEY_BASE = Rails.application.credentials[:secret_key_base]
  JWT_DEFAULT_ALGORITHM = 'HS256'

  module ClassMethods
    def jwt_encode(user_id, expire: 30.days)
      expires_in = expire.from_now.to_i

      preload = {
        iss: Settings.production.host,
        exp: expires_in,
        iat: Time.zone.now.to_i,
        user_id: user_id
      }

      JWT.encode(preload, SECRET_KEY_BASE, JWT_DEFAULT_ALGORITHM)
    end

    def jwt_decode(encoded_token)
      decoded_jwt = JWT.decode(encoded_token, SECRET_KEY_BASE, true, algorithm: JWT_DEFAULT_ALGORITHM)
      decoded_jwt.first.symbolize_keys
    end
  end
end
