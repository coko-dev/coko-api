# frozen_string_literal: true

class KitchenProductHistory < ApplicationRecord
  belongs_to :kitchen
  belongs_to :user
end
