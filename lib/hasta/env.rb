# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/local_file_path'
require 'hasta/s3_data_source'

module Hasta
  # Constructs the ENV variables required to run a local EMR job
  class Env
    attr_reader :variables, :files

    def initialize(
      variables = {},
      files = {},
      combined_storage = Hasta.combined_storage
      )
      @variables = variables
      @files = files
      @combined_storage = combined_storage
    end

    def setup
      file_vars = {}
      files.each do |key, s3_uri|
        input_source = S3DataSource.new(s3_uri, combined_storage)
        file_vars[key] = LocalFilePath.for(combined_storage.write(s3_uri, input_source))
      end

      variables.merge(file_vars)
    end

    private

    attr_reader :combined_storage
  end
end
