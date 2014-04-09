# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/filters'
require 'hasta/filtered_s3_file'

module Hasta
  # Creates a Hasta filtered S3 file instance given a Fog file
  class ResolveFilteredS3File
    def initialize(filters, child_resolver = Hasta::Storage::ResolveS3File)
      @filters = filters
      @child_resolver = child_resolver
    end

    def resolve(fog_file)
      s3_file = child_resolver.resolve(fog_file)
      if filter = filters.for_s3_uri(s3_file.s3_uri)
        FilteredS3File.new(s3_file, filter)
      else
        s3_file
      end
    end

    private

    attr_reader :filters, :child_resolver
  end
end
