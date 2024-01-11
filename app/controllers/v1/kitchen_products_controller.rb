# frozen_string_literal: true

module V1
  class KitchenProductsController < ApplicationController
    before_action :set_kitchen,                     only: %i[index create update destroy recognize]
    before_action :set_kitchen_product,             only: %i[update]

    api :GET, '/v1/kitchen_products', 'Show all products in own kitchen'
    def index
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        @kitchen.kitchen_products.order(:created_at),
        include: associations_for_serialization
      ), status: :ok
    end

    api :POST, '/v1/kitchen_products/recognize'
    param :ingredients_data, String, desc: 'A string containing a list of ingredients, quantities, expiry dates, and notes.'
    def recognize
      client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:api_key])
      system_prompt = <<~SYSTEM_PROMPT
        今日の日付: #{Time.current.strftime('%Y-%m-%d')}
        入力された食材情報をJSONとして出力して下さい。
        それぞれのproductはhiragana_name, best_before, noteを持ちます。

        products: 大枠,
        hiragana_name: 食材の名前(ひらがな表記),
        best_before: 食材の消費期限(fromat: 'yyyy-mm-dd'),
        note: その他の情報(個数など)

        「hiragana_name」は、シンプルな一般名に変換してひらがな表記にしてください。例：「温州ミカン」→「みかん」
        「best_before」は、年月日のいずれかが不足する場合は、「今日の日付」の一部を使って適宜補ってください。例：「11月30」 → 「2023-11-30」
        ただし、「best_before」が全く存在しない場合はただの空文字列にしてください。例：「りんご 三個] → 「hiragana_name: 'りんご', best_before: '', note: '三個'」
      SYSTEM_PROMPT

      response = client.chat(
        parameters: {
          model: 'gpt-4-1106-preview',
          response_format: { type: 'json_object' },
          temperature: 0,
          messages: [
            { role: 'system', content: system_prompt },
            { role: 'user', content: params[:ingredients_data] }
          ]
        }
      )
      finish_reason = response.dig('choices', 0, 'finish_reason')
      raise StandardError, 'Failed to recognize' unless finish_reason == 'stop'

      content = response.dig('choices', 0, 'message', 'content')
      data_hash = JSON.parse(content)
      kitchen_products = data_hash['products'].each_with_object([]) do |product, list|
        name_hira = Product.find_by(name_hira: product['hiragana_name'])
        next unless name_hira

        list << @kitchen.kitchen_products.build(
          product: name_hira,
          note: product['note'],
          best_before: product['best_before']&.to_date
        )
      end

      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_products,
        include: associations_for_serialization
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :POST, '/v1/kitchen_products', 'Create a kitchen product'
    param :kitchen_products, Array, required: true, desc: 'Products' do
      param :product_id, String, required: true, desc: "Parent product's id"
      param :note, String, desc: "User's memo"
      param :added_on, String, desc: "Ex: '2021-10-5' or '2021-10-05'. Default: request date"
      param :best_before, String, desc: "Ex: '2021-10-5' or '2021-10-05'"
    end
    def create
      raise StandardError, 'Add failed. Exceeds the maximum number' if @kitchen.is_subscriber.blank? && KitchenProduct.over_num_limit?(@kitchen, add_num: params[:kitchen_products].length)

      kitchen_products = kitchen_product_create_params.map do |kitchen_product_param|
        product = Product.find(kitchen_product_param[:product_id])
        @kitchen.touch_with_history_build(user: @current_user, product: product, status_id: 'added')
        @kitchen.kitchen_products.build(
          product: product,
          note: kitchen_product_param[:note],
          added_on: kitchen_product_param[:added_on]&.to_date,
          best_before: kitchen_product_param[:best_before]&.to_date
        )
      end
      @kitchen.save!
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        kitchen_products,
        include: associations_for_serialization
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :PUT, '/v1/kitchen_products/:id', 'Update a kitchen product'
    param :note, String, desc: "User's memo"
    param :added_on, String, desc: "Ex: '2021-10-5' or '2021-10-05'. Default: request date"
    param :best_before, String, desc: "Ex: '2021-10-5' or '2021-10-05'"
    def update
      authorize(@kitchen_product)
      @kitchen_product.assign_attributes(kitchen_product_update_params)
      # NOTE: When building with params, no error occurs and it becomes nil.
      added_on = params[:added_on]
      @kitchen_product.added_on = added_on.to_date if added_on.present?
      best_before = params[:best_before]
      @kitchen_product.best_before = best_before.to_date if best_before.present?
      is_changed = @kitchen_product.changed?
      if is_changed
        @kitchen.touch_with_history_build(user: @current_user, product: @kitchen_product.product, status_id: 'updated')
        ApplicationRecord.transaction do
          @kitchen_product.save!
          @kitchen.save!
        end
      end
      render content_type: 'application/json', json: KitchenProductSerializer.new(
        @kitchen_product,
        include: associations_for_serialization,
        meta: {
          is_changed: is_changed
        }
      ), status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    api :DELETE, '/v1/kitchen_products', 'Delete kitchen products'
    param :kitchen_product_ids, Array, required: true, desc: 'Kitchen product ids. Ex: [1, 2, 3]'
    def destroy
      kitchen_products = @kitchen.kitchen_products.where(id: params[:kitchen_product_ids])
      kitchen_products.each { |kp| @kitchen.touch_with_history_build(user: @current_user, product: kp.product, status_id: 'deleted') }
      destroyed = ApplicationRecord.transaction do
        @kitchen.save!
        kitchen_products.destroy_all
      end
      render content_type: 'application/json', json: {
        data: { meta: { destroyed_count: destroyed.size } }
      }, status: :ok
    rescue StandardError => e
      render_bad_request(e)
    end

    private

    def associations_for_serialization
      %i[
        product
      ]
    end

    # NOTE: Don't include 'best_before' in params to make an error if it cannot be converted to date type.
    def kitchen_product_update_params
      params.permit(
        %i[
          note
        ]
      )
    end

    def kitchen_product_create_params
      params.permit(
        kitchen_products: %i[
          product_id
          note
          added_on
          best_before
        ]
      )&.values&.first
    end

    def set_kitchen
      @kitchen = @current_user.kitchen
    end

    def set_kitchen_product
      @kitchen_product = KitchenProduct.find(params[:id])
    end
  end
end
