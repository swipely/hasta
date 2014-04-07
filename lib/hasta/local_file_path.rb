# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/s3_uri'

module Hasta
  # Resolves the local file path for an S3 URI
  module LocalFilePath
    def self.for(s3_uri)
      File.expand_path(File.join(Hasta.local_storage_root, s3_uri.bucket, s3_uri.path))
    end
  end
end
