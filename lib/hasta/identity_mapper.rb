# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Used by any EMR job that required an identity mapper
  module IdentityMapper
    def self.map(data_sources, data_sink = InMemoryDataSink.new)
      Hasta.logger.debug "Starting Identity Mapper"
      data_sources.each do |data_source|
        data_source.each_line do |line|
          data_sink << line
        end
      end

      data_sink.close.tap { Hasta.logger.debug "Finished Identity Mapper" }
    end
  end
end
