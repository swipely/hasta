# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/in_memory_data_sink'
require 'hasta/materialize_class'

module Hasta
  # A wrapper for instantiating a mapper from a definition file and invoking it
  class Mapper
    attr_reader :mapper_file

    def initialize(mapper_file)
      @mapper_file = mapper_file
    end

    def map(data_sources, data_sink = InMemoryDataSink.new('Mapper Output'))
      Hasta.logger.debug "Starting mapper: #{mapper.class.name}"
      data_sources.each { |data_source|
        Hasta.logger.debug "Mapping over data source: #{data_source}"
        data_source.each_line do |line|
          if mapped_line = mapper.map(line.strip)
            data_sink << mapped_line
          end
        end
      }

      data_sink.close
    end

    private

    def mapper
      @mapper ||= MaterializeClass.from_file(mapper_file)
    end
  end
end
