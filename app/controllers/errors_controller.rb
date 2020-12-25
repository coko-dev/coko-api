# frozen_string_literal: true

class ErrorsController < ActionController::API
  rescue_from StandardError, with: :render_server_error
  rescue_from UnauthorizedError, with: :render_unauthorized

  def show
    raise request.env['action_dispatch.exception']
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

  def render_server_error
    render content_type: 'application/json', json: {
      errors: {
        status: '500',
        title: 'Internal Server Error'
      }
    }, status: :internal_server_error
  end
end
