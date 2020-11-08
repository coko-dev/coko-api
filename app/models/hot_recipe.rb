# frozen_string_literal: true

class HotRecipe < ApplicationRecord
  include GoogleCloudStorageUtil

  belongs_to :recipe

  class << self
    def test
      fetch_bucket
    end
  end
end
