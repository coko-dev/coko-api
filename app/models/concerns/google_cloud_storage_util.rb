# frozen_string_literal: true

require 'google/cloud/storage'

module GoogleCloudStorageUtil
  extend ActiveSupport::Concern

  module ClassMethods
    def fetch_bucket
      storage = Google::Cloud::Storage.new(
        project_id: 'coko-prd',
        credentials: Rails.application.credentials.google
      )
      storage.bucket 'coko_bucket'
    end

    def delete_image(bucket: nil, file_name: nil, folder_path: 'test/')
      path = "#{folder_path}#{file_name}"
      file = bucket.file(path)
      file.delete if file.present?
    end

    def upload_image(bucket: nil, image: nil, file_name: nil, folder_path: 'test/')
      path = "#{folder_path}#{file_name}"
      bucket&.create_file(image, path)
    end
  end
end
