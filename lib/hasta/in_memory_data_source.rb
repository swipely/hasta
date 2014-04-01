# Copyright Swipely, Inc.  All rights reserved.

require 'forwardable'

module Hasta
  # Data source for reading data from memory
  class InMemoryDataSource
    attr_reader :name

    def initialize(lines, name=nil)
      @lines = lines
      @name = name
    end

    def each_line
      return enum_for(__callee__) unless block_given?

      lines.each do |line|
        yield line
      end
    end

    def to_a
      lines
    end

    def to_s
      "#<#{self.class.name}:#{name} size=#{lines.count} lines>"
    end

    private

    attr_reader :lines
  end
end
