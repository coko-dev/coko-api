# frozen_string_literal: true

module V1
  class KitchenJoinsController < ApplicationController
    api :POST, '/v1/kitchen_joins', 'Create kitchen joins'
  end
end
