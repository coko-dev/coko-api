# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include AuthUtil
  include RenderErrorUtil

  before_action :authenticate_with_api_token

  class ::UnauthorizedError < StandardError; end

  private

  # :reek:DuplicateMethodCall { exclude: [authenticate_with_api_token] }
  def authenticate_with_api_token
    authenticate_or_request_with_http_token do |token, _options|
      payload = self.class.jwt_decode(token)
      subject = payload[:sub]
      case payload[:typ]
      when 'user'
        @current_user = User.find_by!(code: subject)
      when 'admin_user'
        @admin_user = AdminUser.find(subject)
      end
    rescue JWT::DecodeError => e
      logger.warn(e)
      render_unauthorized
    rescue StandardError => e
      logger.warn(e)
      render_bad_request(detail: e.message)
    end
  end

  # NOTE: Not used
  def temp_auth
    credentials = Rails.application.credentials.temp_auth[:token]
    return if params_token == credentials

    raise UnauthorizedError
  end

  # NOTE: Not used
  def params_token
    params.permit(
      :temp_auth_token
    ).values.first
  end
end
