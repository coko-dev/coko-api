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
      payload = self.class.jwt_decode(token)
      subject = payload[:sub]
      type = payload[:typ]
      raise ForbiddenError unless macthed_routing_for_user_type?(type)

      case type
      when 'user'
        @current_user = User.find_by!(code: subject)
      when 'admin_user'
        @admin_user = AdminUser.find(subject)
      end
    rescue JWT::DecodeError => e
      logger.warn(e)
      render_unauthorized
    rescue ForbiddenError => e
      logger.warn(e)
      render_forbidden
    rescue StandardError => e
      render_bad_request(e)
    end
  end

  def macthed_routing_for_user_type?(type)
    requested = request.path.match(%r{/(.+?)/})[1]
    settings = Settings.routing.namespace

    case type
    when 'user'
      settings.public
    when 'admin_user'
      settings.admin
    end.include?(requested)
  end

  def authenticate_with_base_api_key
    is_valid = request.headers[:HTTP_X_COKO_API_KEY] == Rails.application.credentials.api_access_key

    raise StandardError unless is_valid
  rescue StandardError
    render_manual_bad_request('access key is invalid')
  end
end
