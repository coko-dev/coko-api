# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name = 'CokoApi'
  config.api_base_url = ''
  config.doc_base_url = '/apidoc'
  config.api_controllers_matcher = Rails.root.join('app/controllers/**/*.rb')
  config.api_routes = Rails.application.routes
  config.translate = false
  config.authenticate = proc {
    basic_auth = Rails.application.credentials[:basic_auth]
    authenticate_or_request_with_http_basic do |username, password|
      username == basic_auth[:user_name] && password == basic_auth[:password]
    end
  }
end
