# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Used by any EMR job that required an identity mapper
  module IdentityMapper
    def self.map(data_source, data_sink = InMemoryDataSink.new)
      Hasta.logger.debug "Starting Identity Mapper"
      data_source.each_line do |line|
        data_sink << line
      end

      data_sink.close.tap { Hasta.logger.debug "Finished Identity Mapper" }
    end
  end
end
