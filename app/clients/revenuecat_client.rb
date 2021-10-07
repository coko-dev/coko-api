# frozen_string_literal: true

class RevenuecatClient
  include StringUtil

  TYPES = { kitchen: 'kitchen' }.freeze
  REVENUECAT_API_KEY = Rails.application.credentials.revenuecat[:api_key]

  class << self
    def subscribed?(type: nil, id: nil)
      res = fetch_subscription(type: type, id: id)
      raise StandardError unless res.success?

      body = JSON.parse(res.response_body, symbolize_names: true)
      # NOTE: subscriptions が空、もしくは unsubscribe_detected_at に時刻があれば非課金
      return false if body.dig(:subscriber, :subscriptions).blank? || body.dig(:subscriber, :subscriptions, :plan_name, :unsubscribe_detected_at).present?

      true
    end

    def fetch_subscription(type: nil, id: nil)
      type = TYPES[type]
      return if type.blank? || id.blank?

      Typhoeus.get(
        "https://api.revenuecat.com/v1/subscribers/#{app_user_id(type: type, id: id)}",
        headers: {
          Accept: 'application/json',
          Authorization: "Bearer #{REVENUECAT_API_KEY}",
          'Content-Type' => 'application/json'
        }
      )
    end

    def app_user_id(type:, id:)
      "#{short_env_name}-#{type}-#{id}"
    end
  end
end
