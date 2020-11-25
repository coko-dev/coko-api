# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user, only: %i[update]

    # api :GET, '/v1/users', 'Show the user'
    # def show
    #   recipe_categories = RecipeCategory.all
    #   render json: { recipe_categories: recipe_categories }
    # end

    api :POST, '/v1/users', 'User registration'
    def create
      user = User.new(user_params)
      user.build_profile
      user.build_own_kitchen
      if user.save
        render content_type: 'application/json', json: {
          message: 'Completion of registration'
        }, status: :ok
      else
        errors = user.errors
        messages = errors.messages
        logger.error(messages)
        render content_type: 'application/json', json: {
          errors: [{
            code: '400',
            title: 'Bad request',
            detail: messages.first
          }]
        }, status: :bad_request
      end
    end

    api :PUT, '/v1/users', 'User profiles update'
    def update
      @user.assign_attributes(user_params)
      profile = @user.profile
      profile.assign_attributes(user_profile_params)
      if @user.save
        render content_type: 'application/json', json: {
          message: 'Update completed.'
        }, status: :ok
      else
        errors = @user.errors
        messages = errors.messages
        logger.error(messages)
        # NOTE: ユーザ向けバリデーションエラーを返す
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

    private

    def set_user
      # TODO: Fix to `code`
      @user = User.find(params[:id])
    end

    def user_params
      params.permit(
        :email
      )
    end

    def user_profile_params
      params.permit(
        :user_id,
        :name,
        :birth_date,
        :housework_career,
        :description,
        :website_url
      )
    end
  end
end
