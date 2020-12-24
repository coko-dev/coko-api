# frozen_string_literal: true

class ErrorsController < ActionController::API
  rescue_from UnauthorizedError, with: :render_unauthorized

  def render_unauthorized
    render content_type: 'application/json', json: { errors: [{ status: '401', title: 'Unauthorized', detail: 'Invalid credentials' }] }, status: :unauthorized
  end
end
