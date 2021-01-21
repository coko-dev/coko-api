# frozen_string_literal: true

require 'google/cloud/storage'

module GoogleCloudStorageUtil
  extend ActiveSupport::Concern

  FOLDERS_BY_TYPE = {
    user: 'users/',
    product: 'products/'
  }.freeze

  module ClassMethods
    def fetch_bucket
      credentials = Rails.application.credentials.gcp
      storage = Google::Cloud::Storage.new(credentials: credentials[:service_account])
      storage.bucket(credentials[:gcs][:bucket])
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

    def upload_and_fetch_image(subject: nil, encoded_image: nil, type: nil)
      return if %w[subject encoded_image type].any?(nil) || FOLDERS_BY_TYPE.keys.exclude?(type)

      bin = Base64.decode64(encoded_image)
      bucket = fetch_bucket
      file_name = "#{subject}-#{Time.zone.now}.png"
      tmp_path = "#{Rails.root}/tmp/#{file_name}"
      gcs_image = File.open(tmp_path, 'wb+') do |file|
        file.write(bin)
        path = "#{FOLDERS_BY_TYPE[type]}#{file_name}"
        bucket&.create_file(file, path)
      end
      File.delete(tmp_path)
      gcs_image.signed_url
    end
  end
end
