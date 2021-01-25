# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name     = 'CokoApi'
  config.api_base_url = ''
  config.doc_base_url = '/apidoc'
  # where is your API defined?
  config.api_controllers_matcher = Rails.root.join('/app/controllers/**/*.rb')
  config.api_routes = Rails.application.routes
  config.translate = false
end
