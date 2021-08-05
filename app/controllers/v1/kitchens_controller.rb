# frozen_string_literal: true

module V1
  class KitchensController < ApplicationController
    api :GET, '/v1/kitchens/current', 'Show current kitchen'
    def show_current_kitchen
      render content_type: 'application/json', json: KitchenSerializer.new(
        @current_user.kitchen
      ), status: :ok
    end

    api :PUT, '/v1/kitchen', 'Update current kitchen'
    param :name, String, allow_blank: true, desc: 'Kitchen name'
    def update
      kitchen = @current_user.kitchen
      kitchen.update!(name: params[:name])
      render content_type: 'application/json', json: KitchenSerializer.new(
        kitchen
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
