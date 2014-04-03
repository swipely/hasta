# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/combined_data_source'
require 'hasta/execution_context'
require 'hasta/in_memory_data_sink'

module Hasta
  # A wrapper for instantiating a mapper from a definition file and invoking it
  class Mapper
    attr_reader :mapper_file

    def initialize(mapper_file)
      @mapper_file = mapper_file
    end

    def map(execution_context, data_sources, data_sink = InMemoryDataSink.new('Mapper Output'))
      Hasta.logger.debug "Starting mapper: #{mapper_file}"

      data_source = CombinedDataSource.new(data_sources)
      execution_context.execute(mapper_file, data_source, data_sink)
    end
  end
end
