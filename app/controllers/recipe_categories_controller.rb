# frozen_string_literal: true

class RecipeCategoriesController < ApplicationController
  def root
    # TODO: Delete this comment later
    render json: { status: 'SUCCESS', message: 'API ROOT' }
  end
end
