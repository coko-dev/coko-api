# frozen_string_literal: true

module V1
  class UserProfilesController < ApplicationController
    api :PUT, '/v1/user_profiles', 'User profiles update.'
    def update
      user = User.find(user_profile_params[:user_id])
      profile = user.profile
      if profile.save
        render content_type: 'application/json', json: {
          message: 'Update completed.'
        }, status: :ok
      else
        errors = profile.errors
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
