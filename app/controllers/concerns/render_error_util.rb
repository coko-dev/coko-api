# frozen_string_literal: true

module RenderErrorUtil
  extend ActiveSupport::Concern

  def render_bad_request(object)
    errors = object.errors
    messages = errors.messages
    logger.error(messages)
    render content_type: 'application/json', json: {
      errors: {
        code: '400',
        title: 'Bad request',
        detail: errors.first.join
      }
    }, status: :bad_request
  end

  def render_origin_bad_request(title, detail)
    render content_type: 'application/json', json: {
      errors: {
        code: '400',
        title: title,
        detail: detail
      }
    }, status: :bad_request
  end
end
