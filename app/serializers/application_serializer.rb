# frozen_string_literal: true

class ApplicationSerializer
  include StringUtil
  include JSONAPI::Serializer

  class << self
    def myself_record?(record, current_user)
      current_user.present? && record.myself?(current_user)
    end
  end
end
