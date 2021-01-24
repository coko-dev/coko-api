# frozen_string_literal: true

module RenderErrorUtil
  extend ActiveSupport::Concern

  def render_bad_request(exception = nil)
    render content_type: 'application/json', json: {
      errors: {
        status: '400',
        title: 'Bad Request',
        detail: exception&.message
      }.compact
    }, status: :bad_request
  end

  def render_manual_bad_request(title, detail)
    render content_type: 'application/json', json: {
      errors: {
        status: '400',
        title: title,
        detail: detail
      }
    }, status: :bad_request
  end

  def render_unauthorized
    render content_type: 'application/json', json: {
      errors: {
        status: '401',
        title: 'Unauthorized',
        detail: 'Invalid credentials'
      }
    }, status: :unauthorized
  end

  def render_forbidden
    render content_type: 'application/json', json: {
      errors: {
        status: '403',
        title: 'Forbidden'
      }
    }, status: :forbidden
  end

  def render_not_found
    render content_type: 'application/json', json: {
      errors: {
        status: '404',
        title: 'Not Found'
      }
    }, status: :not_found
  end

  def render_method_not_allowed
    render content_type: 'application/json', json: {
      errors: {
        status: '405',
        title: 'Method Not Allowed'
      }
    }, status: :method_not_allowed
  end

  def render_server_error
    render content_type: 'application/json', json: {
      errors: {
        status: '500',
        title: 'Internal Server Error'
      }
    }, status: :internal_server_error
  end
end
