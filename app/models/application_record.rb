# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include StringUtil

  before_create :set_id

  def set_id
    return if self[:id].present?

    klass = self.class
    self[:id] = loop do
      generated_id = klass.generate_random_code(length: 12)
      break generated_id unless klass.exists?(id: generated_id)
    end
  end
end
