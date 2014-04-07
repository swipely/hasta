# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/execution_context'
require 'hasta/in_memory_data_sink'
require 'hasta/sorted_data_source'

module Hasta
  # A wrapper for instantiating a reducer from a definition file and invoking it
  class Reducer
    attr_reader :reducer_file

    def initialize(reducer_file)
      @reducer_file = reducer_file
    end

    def reduce(execution_context, data_source, data_sink = InMemoryDataSink.new("Reducer Output"))
      Hasta.logger.debug "Starting reducer: #{reducer_file}"
      execution_context.execute(reducer_file, sorted_data_source(data_source), data_sink)

      data_sink.close
    end

    private

    def sorted_data_source(data_source)
      SortedDataSource.new(data_source)
    end
  end
end
