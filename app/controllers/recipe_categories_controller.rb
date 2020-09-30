# frozen_string_literal: true

class RecipeCategoriesController < ApplicationController
  def root
    render json: { status: 'SUCCESS', message: 'API ROOT' }
  end
end
