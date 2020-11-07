# frozen_string_literal: true

require 'google/cloud/storage'

module GoogleCloudStorageUtil
  def fetch_bucket
    storage = Google::Cloud::Storage.new(
      project_id: 'coko-prd',
      credentials: 'config/coko-prd-bb136db46046.json'
    )
    storage.bucket 'coko_bucket'
  end
end
