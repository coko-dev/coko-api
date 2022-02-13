# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include AuthUtil
  include Pundit
  include RenderErrorUtil

  before_action :authenticate_with_base_api_key
  before_action :authenticate_with_api_token

  private

  def pundit_user
    @current_user || @admin_user
  end

  def authenticate_with_api_token
    authenticate_or_request_with_http_token do |token, _options|
      payload = self.class.jwt_decode_for_firebase(token)
      subject = payload[:sub]
      @current_user = User.allowed.find_by!(code: subject)
    rescue JWT::DecodeError => e
      logger.warn(e)
      render_unauthorized
    rescue RecordNotFound => e
      logger.warn(e)
      render_not_found
    rescue StandardError => e
      render_bad_request(e)
    end
  end

  def authenticate_with_base_api_key
    return if request.headers[:HTTP_X_COKO_API_KEY] == Rails.application.credentials.api_access_key

    raise StandardError, 'Access key is invalid'
  rescue StandardError => e
    render_bad_request(e)
  end
end
