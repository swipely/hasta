# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/s3_uri'
require 'hasta/storage'

module Hasta
  # The file storage interface used by the local map/reduce jobs
  class CombinedStorage
    def initialize(s3_storage, local_storage)
      @s3_storage = s3_storage
      @local_storage = local_storage
    end

    def files_for(s3_uri)
      if local_storage.exists?(s3_uri)
        local_storage.files_for(s3_uri)
      else
        s3_storage.files_for(s3_uri)
      end
    end

    def write(s3_uri, data_source)
      local_storage.write(s3_uri, data_source)
    end

    private

    attr_reader :s3_storage, :local_storage
  end
end
