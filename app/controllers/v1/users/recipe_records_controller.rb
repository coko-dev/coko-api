# frozen_string_literal: true

module V1
  module Users
    class RecipeRecordsController < ApplicationController
      before_action :set_user, only: %i[index]

      api :GET, '/v1/users/:user_code/recipe_records', 'Show recipe records related to a user'
      def index
        recipe_records = @user.recipe_records.order(created_at: :desc).limit(12)
        render content_type: 'application/json', json: RecipeRecordSerializer.new(
          recipe_records,
          include: associations_to_include
        ), status: :ok
      end

      private

      def set_user
        @user = User.find_by!(code: params[:user_code])
        raise ForbiddenError if @user.is_private? && @user != @current_user
      end

      def associations_to_include
        %i[
          recipe
          author
        ]
      end
    end
  end
end
