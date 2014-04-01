# Copyright Swipely, Inc.  All rights reserved.

require 'fog'

require 'hasta/s3_uri'
require 'hasta/storage'

module Hasta
  # The read/write file storage interface to the local representation of the S3 data used
  # by the local map/reduce jobs
  class LocalStorage
    include Storage

    def write(s3_uri, data_source)
      contents = StringIO.new
      data_source.each_line do |line|
        contents << line
      end

      write_to(
        s3_uri.file? ? s3_uri : s3_uri.append('part-00000'),
        contents.string
      )
    end

    private

    def write_to(s3_uri, contents)
      write_bucket = bucket(s3_uri) || create_bucket(s3_uri.bucket)
      file = create_file(write_bucket, s3_uri.path, contents)

      s3_uri
    end

    def files(s3_bucket, s3_uri)
      s3_bucket.files.select { |file|
        file.key.start_with?(s3_uri.path) && file_s3_uri(file).parent == s3_uri
      }
    end
  end
end
