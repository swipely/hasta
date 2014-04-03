# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Combines multiple data sources so they can be iterated over continuously
  class CombinedDataSource
    attr_reader :name

    def initialize(sources, name = nil)
      @sources = sources
      @name = name || sources.map(&:name).compact.join(', ')
    end

    def each_line
      return enum_for(:each_line) unless block_given?

      sources.each do |source|
        source.each_line do |line|
          yield line
        end
      end
    end

    def to_a
      each_line.to_a
    end

    def to_s
      "#<#{self.class.name}:#{name}>"
    end

    private

    attr_reader :sources
  end
end
