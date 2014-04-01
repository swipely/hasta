# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/s3_uri'
require 'hasta/combined_storage'

module Hasta
  # Data source for reading data from S3
  class S3DataSource
    def initialize(s3_uri, combined_storage = Hasta.combined_storage)
      @s3_uri = s3_uri
      @combined_storage = combined_storage
    end

    def each_line
      return enum_for(:each_line) unless block_given?

      combined_storage.files_for(s3_uri).each do |file|
        Hasta.logger.debug "Processing file: #{file.key}"
        StringIO.new(file.body).each_line { |line| yield line }
      end
    end

    def to_a
      each_line.to_a
    end

    def to_s
      "#<#{self.class.name}:#{s3_uri}>"
    end

    private

    attr_reader :s3_uri, :combined_storage
  end
end
