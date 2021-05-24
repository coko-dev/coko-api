# frozen_string_literal: true

module Admin
  class HotRecipeVersionsController < ApplicationController
    before_action :set_version, only: %i[enable]
    
    api :GET, '/admin/hot_recipe_versions', 'Show enabled version'
    def index
      render content_type: 'application/json', json: HotRecipeVersionSerializer.new(
        HotRecipeVersion.order(created_at: :desc).limit(20)
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
    
    api :POST, '/admin/hot_recipe_versions', 'Register hot recipe version. Default hidden'
    param :version, String, required: true, desc: 'Version name'
    def create
      hot_recipe_version = HotRecipeVersion.create!(version: params[:version])
      render content_type: 'application/json', json: HotRecipeVersionSerializer.new(
        hot_recipe_version
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/admin/hot_recipe_versions/:version/enable', 'Enable specified version'
    param :version, String, required: true, desc: 'Version name'
    def enable
      @version.enabled!
      render content_type: 'application/json', json: HotRecipeVersionSerializer.new(
        @version
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def set_version
      @version = HotRecipeVersion.find_by!(version: params[:version])
    end
  end
end
