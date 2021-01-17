# frozen_string_literal: true

class ErrorsController < ActionController::API
  include RenderErrorUtil

  rescue_from StandardError, with: :render_server_error
  rescue_from UnauthorizedError, with: :render_unauthorized
  rescue_from ForbiddenError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from AbstractController::ActionNotFound, with: :render_method_not_allowed

  def show
    raise request.env['action_dispatch.exception']
  end
end
