# Copyright Swipely, Inc.  All rights reserved.

require 'delegate'

module Hasta
  # Implements Hasta's S3File interface for files retrieved from the cache
  class CachedS3File < SimpleDelegator
    def initialize(cached_file, s3_uri)
      super(S3File.wrap(cached_file))
      @s3_uri = s3_uri
    end

    def key
      @s3_uri.path
    end

    def s3_uri
      @s3_uri
    end
  end
end
