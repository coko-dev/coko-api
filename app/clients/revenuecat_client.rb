# frozen_string_literal: true

include StringUtil

class RevenuecatClient
  APP_UID_PREFIX = '$RCAnonymousID:'
  TYPE_PREFIX = { kitchen: 'kitchen' }
  REVENUECAT_API_KEY = Rails.application.credentials.revenuecat[:api_key]

  class << self
    def subscribed?(type: nil, id: nil)
      res = fetch_subscription(type: type, id: id)
      raise StandardError unless res.success?

      body = JSON.parse(res.response_body, symbolize_names: true)
      return false if body.dig(:subscriber, :subscriptions).blank? || body.dig(:subscriber, :subscriptions, :plan_name, :unsubscribe_detected_at).present?

      true
    end

    def fetch_subscription(type: nil, id: nil)
      type_prefix = TYPE_PREFIX[type]
      return if type_prefix.blank? || id.blank?

      app_user_id = "#{APP_UID_PREFIX}#{short_env_name}-#{type_prefix}-#{id}"
      Typhoeus.get(
        "https://api.revenuecat.com/v1/subscribers/#{app_user_id}",
        headers: {
          Accept: 'application/json',
          Authorization: "Bearer #{REVENUECAT_API_KEY}",
          'Content-Type' => 'application/json'
        }
      )
    end
  end
end
