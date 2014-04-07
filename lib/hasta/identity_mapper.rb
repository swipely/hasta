# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/combined_data_source'

module Hasta
  # Used by any EMR job that required an identity mapper
  module IdentityMapper
    def self.map(_, data_sources, data_sink = InMemoryDataSink.new)
      Hasta.logger.debug "Starting Identity Mapper"
      CombinedDataSource.new(data_sources).each_line do |line|
        data_sink << line.rstrip
      end

      data_sink.close.tap { Hasta.logger.debug "Finished Identity Mapper" }
    end
  end
end
