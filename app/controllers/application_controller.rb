# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :temp_auth

  def temp_auth
    credentials = Rails.application.credentials.temp_auth[:token]
    return if params_token == credentials

    render content_type: 'application/json', json: {
      errors: [{
        code: '400',
        title: 'Bad request'
      }]
    }, status: :bad_request
  end

  def params_token
    params.permit(
      :temp_auth_token
    ).values.first
  end
end
