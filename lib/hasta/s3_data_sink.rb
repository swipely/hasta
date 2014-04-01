# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/local_file_path'

module Hasta
  # Data sink for writing data to S3 storage
  class S3DataSink
    attr_reader :s3_uri

    def initialize(s3_uri, combined_storage = Hasta.combined_storage)
      @s3_uri = s3_uri
      @combined_storage = combined_storage
    end

    def <<(line)
      lines << line
    end

    def close
      storage_uri = combined_storage.write(s3_uri, contents)
      Hasta.logger.debug(
        "Wrote #{lines.count} lines to uri: #{storage_uri} (#{LocalFilePath.for(storage_uri)})"
      )

      self
    end

    def data_source
      S3DataSource.new(s3_uri, combined_storage)
    end

    def to_s
      "#<#{self.class.name}:#{s3_uri}>"
    end

    private

    attr_reader :combined_storage

    def lines
      @lines ||= []
    end

    def contents
      lines.join("\n")
    end
  end
end
