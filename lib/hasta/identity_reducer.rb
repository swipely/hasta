# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/in_memory_data_sink'
require 'hasta/sorted_data_source'

module Hasta
  # Used by any EMR job that requires an identity reducer
  module IdentityReducer
    def self.reduce(_, data_source, data_sink = InMemoryDataSink.new)
      Hasta.logger.debug "Starting Identity Reducer"
      SortedDataSource.new(data_source).each_line do |line|
        data_sink << line.rstrip
      end

      data_sink.close.tap { Hasta.logger.debug "Finished Identity Reducer" }
    end
  end
end
