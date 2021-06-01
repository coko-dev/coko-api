# frozen_string_literal: true

module AuthUtil
  require 'jwt'

  extend ActiveSupport::Concern

  SECRET_KEY_BASE = Rails.application.credentials[:secret_key_base]
  JWT_DEFAULT_ALGORITHM = 'HS256'
  JWT_FIREBASE_ALGORITHM = 'RS256'
  CONTENT_TYPES = %w[user admin_user].freeze

  module ClassMethods
    def jwt_encode_for_general(subject: nil, type: nil, expire: 30.days)
      return if subject.blank? || type.blank? || CONTENT_TYPES.exclude?(type)

      expires_in = expire.from_now.to_i

      JWT.encode(
        {
          iss: Settings.production.host,
          sub: subject,
          exp: expires_in,
          iat: Time.zone.now.to_i,
          typ: type
        },
        SECRET_KEY_BASE,
        JWT_DEFAULT_ALGORITHM
      )
    end

    def jwt_decode_for_general(encoded_token)
      JWT.decode(encoded_token, SECRET_KEY_BASE, true, algorithm: JWT_DEFAULT_ALGORITHM).first.symbolize_keys
    end

    def jwt_encode_for_firebase(subject: nil, type: nil, expire: 1.hour)
      return if subject.blank? || type.blank? || CONTENT_TYPES.exclude?(type)

      expires_in = expire.from_now.to_i

      JWT.encode(
        {
          iss: Settings.production.host,
          sub: subject,
          exp: expires_in,
          iat: Time.zone.now.to_i,
          typ: type
        },
        firebase_private_key,
        JWT_FIREBASE_ALGORITHM,
        typ: 'JWT'
      )
    end

    def jwt_decode_for_firebase(encoded_token)
      JWT.decode(encoded_token, firebase_private_key, true, algorithm: JWT_FIREBASE_ALGORITHM).first.symbolize_keys
    end

    def firebase_private_key
      OpenSSL::PKey::RSA.new(Rails.application.credentials.firebase[:credentials][:private_key])
    end
  end
end
