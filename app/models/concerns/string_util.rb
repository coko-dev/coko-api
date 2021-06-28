# frozen_string_literal: true

require 'securerandom'

module StringUtil
  extend ActiveSupport::Concern

  module ClassMethods
    def generate_random_code(length: 8)
      SecureRandom.alphanumeric(length)
    end

    def generate_random_number(length: 6)
      limit = 10**length
      SecureRandom.random_number(limit)
    end

    def number_for_display(number)
      digits = { 100_000_000 => '億', 10_000 => '万' }.freeze
      display_num = number
      digit = ''

      digits.each do |n, d|
        next if number < n

        display_num = (number.to_f / n).ceil(1)
        digit = d
        break
      end

      display_num =
        if display_num >= 1_000
          display_num.ceil.to_s(:delimited)
        else
          display_num.to_s
        end

      "#{display_num}#{digit}"
    end
  end
end
