# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/cached_s3_file'
require 'hasta/s3_file_cache'

module Hasta
  # Retrieves a file from the local cache instead of S3,
  # or retrieves it from S3 and caches it locally
  class ResolveCachedS3File
    def initialize(file_cache, child_resolver)
      @file_cache = file_cache
      @child_resolver = child_resolver
    end

    def resolve(fog_file)
      resolved = child_resolver.resolve(fog_file)
      if cached_file = file_cache.get(resolved.fingerprint)
        Hasta.logger.debug "Retrieved file: #{resolved.s3_uri} from local cache"
        CachedS3File.new(cached_file, resolved.s3_uri)
      else
        file_cache.put(resolved.fingerprint, resolved.body)
        Hasta.logger.debug "Cached file: #{resolved.s3_uri} locally"
        resolved
      end
    end

    attr_reader :file_cache, :child_resolver
  end
end
