# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name     = 'CokoApi'
  config.api_base_url = ''
  config.doc_base_url = '/apipie'
  # where is your API defined?
  config.api_controllers_matcher = Rails.root.join('/app/controllers/**/*.rb')
end
