# frozen_string_literal: true

module AuthUtil
  require 'jwt'

  extend ActiveSupport::Concern

  SECRET_KEY_BASE = Rails.application.credentials[:secret_key_base]
  JWT_DEFAULT_ALGORITHM = 'HS256'
  JWT_FIREBASE_ALGORITHM = 'RS256'
  JWT_FIREBASE_AUDIENCE = 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit'

  module ClassMethods
    def jwt_encode_for_general(subject: nil, expire: 30.days)
      return if subject.blank?

      expires_in = expire.from_now.to_i

      JWT.encode(
        {
          iss: Settings.production.host,
          sub: subject,
          exp: expires_in,
          iat: Time.zone.now.to_i,
          typ: 'admin'
        },
        SECRET_KEY_BASE,
        JWT_DEFAULT_ALGORITHM
      )
    end

    def jwt_decode_for_general(encoded_token)
      JWT.decode(encoded_token, SECRET_KEY_BASE, true, algorithm: JWT_DEFAULT_ALGORITHM).first.symbolize_keys
    end

    def jwt_encode_for_firebase(subject: nil, expire: 1.hour)
      return if subject.blank?

      service_account_email = firebase_credentials[:client_email]
      now_seconds = Time.zone.now.to_i
      expired_at = expire + now_seconds

      JWT.encode(
        {
          iss: service_account_email,
          sub: service_account_email,
          aud: JWT_FIREBASE_AUDIENCE,
          exp: expired_at,
          iat: now_seconds,
          uid: subject,
          typ: 'user'
        },
        firebase_private_key,
        JWT_FIREBASE_ALGORITHM,
        typ: 'JWT'
      )
    end

    def jwt_decode_for_firebase(encoded_token)
      JWT.decode(encoded_token, firebase_private_key, true, algorithm: JWT_FIREBASE_ALGORITHM).first.symbolize_keys
    end

    def firebase_credentials
      Rails.application.credentials.firebase[:credentials]
    end

    def firebase_private_key
      OpenSSL::PKey::RSA.new(firebase_credentials[:private_key])
    end
  end
end
