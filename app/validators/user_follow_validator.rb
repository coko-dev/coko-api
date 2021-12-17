# frozen_string_literal: true

class UserFollowValidator < ApplicationValidator
  def validate(record)
    record.errors.add('User is myself') if record.user_id_to == record.user_id_from
  end
end
