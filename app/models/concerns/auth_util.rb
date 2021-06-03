# frozen_string_literal: true

module AuthUtil
  require 'jwt'

  extend ActiveSupport::Concern

  SECRET_KEY_BASE = Rails.application.credentials[:secret_key_base]
  JWT_DEFAULT_ALGORITHM = 'HS256'
  CONTENT_TYPES = %w[user admin_user].freeze

  module ClassMethods
    def jwt_encode(subject: nil, type: nil, expire: 30.days)
      return if subject.blank? || type.blank? || CONTENT_TYPES.exclude?(type)

      expires_in = expire.from_now.to_i

      preload = {
        iss: Settings.production.host,
        sub: subject,
        exp: expires_in,
        iat: Time.zone.now.to_i,
        typ: type
      }

      JWT.encode(preload, SECRET_KEY_BASE, JWT_DEFAULT_ALGORITHM)
    end

    def jwt_decode(encoded_token)
      decoded_jwt = JWT.decode(encoded_token, SECRET_KEY_BASE, true, algorithm: JWT_DEFAULT_ALGORITHM)
      decoded_jwt.first.symbolize_keys
    end
  end
end
