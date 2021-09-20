# frozen_string_literal: true

module V1
  class KitchenRevenuecatsController < ApplicationController
    api :POST, 'v1/kitchen_revenuecat', 'Create revenuecat for self kitchen'
    param :app_user_id, String, required: true, desc: 'Revenuecat app user id'
    def create
      # TODO:
      # app_user_id と receipt で REST API を叩く
      # 課金状態が確認できたら kitchen のサブスクのステータスを更新する
      # receipt 情報は params ではなく res からだけでいいかも
      res = Typhoeus.get(
        'https://www.example.com',
        params: {
          app_user_id: 'app_user_id'
        },
        headers: {
          Accept: 'application/json',
          Authorization: 'Bearer REVENUECAT_API_KEY',
          'X-Platform': 'platform',
          'Content-Type': 'application/json'
        }
      )

      raise StandardError unless res.success?

      # TODO: 期限などはパラメータからではなく res の 値を使う（ユーザのレシート情報は参照しない）
      revenuecat = KitchenRevenuecat.find_or_initialize_by(kitchen: @current_user.kitchen, app_user_id: params[:app_user_id], receipt: 'receipt')
      if revenuecat.new_record?
        # TODO: ステータス更新など
        revenuecat.save!
      end

      render content_type: 'application/json', json: KitchenRevenuecatSerializer.new(
        revenuecat
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end
  end
end
