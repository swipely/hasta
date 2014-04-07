# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/in_memory_data_source'

module Hasta
  # Data sink for writing data in-memory
  class InMemoryDataSink
    attr_reader :name

    def initialize(name=nil)
      @name = name
    end

    def <<(line)
      lines << Hasta.tab_separated_line(line)
    end

    def data_source
      InMemoryDataSource.new(lines, name)
    end

    def close
      self
    end

    def to_s
      if name
        "#<#{self.class.name}:#{name} (#{lines.count} lines)>"
      else
        super
      end
    end

    private

    def lines
      @lines ||= []
    end
  end
end
