# frozen_string_literal: true

class RecipeCategoriesController < ApplicationController
  api :GET, '/', 'Show the recipe category'
  def root
    render json: { status: 'SUCCESS', message: 'API ROOT' }
  end
end
