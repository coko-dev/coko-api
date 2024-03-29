# frozen_string_literal: true

module RenderErrorUtil
  extend ActiveSupport::Concern

  # rubocop:disable Layout/EmptyLineBetweenDefs
  class UnauthorizedError < StandardError; end
  class ForbiddenError < StandardError; end
  class UserNotFoundError < StandardError; end
  # rubocop:enable Layout/EmptyLineBetweenDefs

  def render_bad_request(exception = nil)
    message = exception&.message || 'Bad request error'
    logger.error(message)
    render content_type: 'application/json', json: {
      errors: {
        status: '400',
        title: 'Bad Request',
        code: '10001',
        detail: message
      }.compact
    }, status: :bad_request
  end

  def render_unauthorized
    render content_type: 'application/json', json: {
      errors: {
        status: '401',
        title: 'Unauthorized',
        code: '10002',
        detail: 'Invalid credentials'
      }
    }, status: :unauthorized
  end

  def render_forbidden
    render content_type: 'application/json', json: {
      errors: {
        status: '403',
        code: '10003',
        title: 'Forbidden'
      }
    }, status: :forbidden
  end

  def render_user_not_found
    render content_type: 'application/json', json: {
      errors: {
        status: '404',
        code: '10004',
        title: 'User Not Found'
      }
    }, status: :not_found
  end

  def render_not_found
    render content_type: 'application/json', json: {
      errors: {
        status: '404',
        code: '10005',
        title: 'Not Found'
      }
    }, status: :not_found
  end

  def render_method_not_allowed
    render content_type: 'application/json', json: {
      errors: {
        status: '405',
        code: '10006',
        title: 'Method Not Allowed'
      }
    }, status: :method_not_allowed
  end

  def render_server_error
    render content_type: 'application/json', json: {
      errors: {
        status: '500',
        code: '20001',
        title: 'Internal Server Error'
      }
    }, status: :internal_server_error
  end
end
