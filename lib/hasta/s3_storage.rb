# Copyright Swipely, Inc.  All rights reserved.

require 'fog'

require 'hasta/s3_uri'
require 'hasta/storage'

module Hasta
  # The read-only file storage interface to the actual S3 data used by the local map/reduce jobs
  class S3Storage
    include Storage

    private

    def fog_files(s3_bucket, s3_uri)
      s3_bucket.files.all('prefix' => s3_uri.path).reject { |file|
        file.key == s3_uri.path || (file_s3_uri(file).parent != s3_uri)
      }
    end
  end
end
