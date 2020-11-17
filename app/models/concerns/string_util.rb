# frozen_string_literal: true

require 'securerandom'

module StringUtil
  module ClassMethods
    def generate_random_code(length: 8)
      SecureRandom.alphanumeric(length)
    end
  end
end
