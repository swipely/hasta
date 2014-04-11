# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Caches data in a flat namespace using Fog storage
  class S3FileCache
    def initialize(fog_storage, bucket_name = 'cache')
      directories = fog_storage.directories
      @bucket = directories.get(bucket_name) || directories.create(:key => bucket_name)
    end

    def get(key)
      bucket.files.get(key)
    end

    def put(key, data)
      bucket.files.create(:key => key, :body => data)
    end

    private

    attr_reader :bucket
  end
end
