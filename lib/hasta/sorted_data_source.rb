# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Decorator for a data source that yields the contents in sorted order
  class SortedDataSource
    def initialize(data_source, sort_by)
      @data_source = data_source
      @sort_by = sort_by
    end

    def name
      data_source.name
    end

    def each_line
      sorted_lines.each do |line|
        yield line
      end
    end

    def to_s
      "#<#{self.class.name}:#{name} size=#{lines.count} lines>"
    end

    private

    attr_reader :data_source, :sort_by

    def sorted_lines
      sorted = if sort_by
        data_source.to_a.sort_by(&sort_by)
      else
        data_source.to_a.sort
      end

      sorted.tap do
        Hasta.logger.debug "Finished sorting data for source: #{data_source}"
      end
    end
  end
end
