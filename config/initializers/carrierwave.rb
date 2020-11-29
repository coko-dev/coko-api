# frozen_string_literal: true

CarrierWave.configure do |config|
  url = Rails.env.production? ? Settings.production.url : Settings.develop.url
  config.asset_host = url
end
