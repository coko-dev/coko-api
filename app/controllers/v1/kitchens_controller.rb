# frozen_string_literal: true

module V1
  class KitchensController < ApplicationController
    before_action :set_kitchen

    api :GET, '/v1/kitchens/current', 'Show current kitchen'
    def show_current_kitchen
      render content_type: 'application/json', json: KitchenSerializer.new(
        @kitchen,
        include: associations_for_serialization,
        params: serializer_params
      ), status: :ok
    end

    api :PUT, '/v1/kitchen', 'Update current kitchen'
    param :name, String, allow_blank: true, desc: 'Kitchen name'
    def update
      @kitchen.update!(name: params[:name])
      render content_type: 'application/json', json: KitchenSerializer.new(
        @kitchen,
        include: associations_for_serialization,
        params: serializer_params
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    def set_kitchen
      @kitchen = @current_user.kitchen
    end

    def associations_for_serialization
      %i[
        users
      ]
    end

    def serializer_params
      { current_user: @current_user }
    end
  end
end
