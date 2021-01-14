# frozen_string_literal: true

class ApplicationController < ActionController::API
  include AuthUtil
  include RenderErrorUtil

  before_action :authenticate_with_api_token

  class ::UnauthorizedError < StandardError; end

  private

  # :reek:DuplicateMethodCall { exclude: [authenticate_with_api_token] }
  def authenticate_with_api_token
    encoded_token = request.headers['Authorization']
    raise UnauthorizedError if encoded_token.blank?

    payload = self.class.jwt_decode(encoded_token)
    @current_user = User.find_by(code: payload[:sub])
    raise UnauthorizedError if @current_user.blank?
  end

  # NOTE: Not used
  def temp_auth
    credentials = Rails.application.credentials.temp_auth[:token]
    return if params_token == credentials

    render content_type: 'application/json', json: {
      errors: [{
        code: '401',
        title: 'Unauthorized'
      }]
    }, status: :unauthorized
  end

  # NOTE: Not used
  def params_token
    params.permit(
      :temp_auth_token
    ).values.first
  end
end
