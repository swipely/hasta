# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Decorator for a data source that yields the contents in sorted order
  class SortedDataSource
    def initialize(data_source)
      @data_source = data_source
    end

    def name
      data_source.name
    end

    def each_line
      return enum_for(:each_line) unless block_given?

      sorted_lines.each do |line|
        yield line
      end
    end

    def to_s
      "#<#{self.class.name}:#{name} size=#{lines.count} lines>"
    end

    private

    attr_reader :data_source

    def sorted_lines
      data_source.to_a.sort.tap do
        Hasta.logger.debug "Finished sorting data for source: #{data_source}"
      end
    end
  end
end
