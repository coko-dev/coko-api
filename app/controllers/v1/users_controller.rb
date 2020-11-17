# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    # api :GET, '/v1/users', 'Show the user'
    # def Show
    #   recipe_categories = RecipeCategory.all
    #   render json: { recipe_categories: recipe_categories }
    # end

    api :POST, '/v1/users', 'User registration'
    def create
      user = User.new(user_params)
      if user.save
        render content_type: 'application/json', json: {
          message: 'Completion of registration'
        }, status: :ok
      else
        errors = user.errors
        messages = errors.messages
        logger.error(messages)
        message_for_cli = messages.values.flatten.last
        render content_type: 'application/json', json: {
          errors: [{
            code: '400',
            title: 'Bad request',
            detail: message_for_cli
          }]
        }, status: :bad_request
      end
    end

    def user_params
      params.require(:user).permit(
        :email
      )
    end
  end
end
