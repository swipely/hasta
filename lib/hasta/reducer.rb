# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/in_memory_data_sink'
require 'hasta/materialize_class'
require 'hasta/sorted_data_source'

module Hasta
  # A wrapper for instantiating a reducer from a definition file and invoking it
  class Reducer
    attr_reader :reducer_file

    def initialize(reducer_file, sort_by = Hasta.sort_by)
      @reducer_file = reducer_file
      @sort_by = sort_by
    end

    def reduce(data_source, data_sink = InMemoryDataSink.new("Reducer Output"))
      Hasta.logger.debug "Starting reducer: #{reducer.class.name}"
      if reducer.respond_to? :reduce_over
        reducer.reduce_over(sorted_data_source(data_source).each_line) do |line|
          data_sink << line
        end
      else
        sorted_data_source(data_source).each_line do |line|
          if reduced = reducer.reduce(line.strip)
            data_sink << reduced
          end
        end
      end

      data_sink.close
    end

    private

    attr_reader :sort_by

    def reducer
      @reducer ||= MaterializeClass.from_file(reducer_file)
    end

    def sorted_data_source(data_source)
      SortedDataSource.new(data_source, sort_by)
    end
  end
end
