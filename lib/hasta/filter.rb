# Copyright Swipely, Inc.  All rights reserved.

require 'set'

module Hasta
  # The filter that is used to drop unwanted lines from input files
  class Filter
    def self.from_file(file)
      if lines = File.read(file)
        Hasta.logger.debug "Loading data filter file: #{File.expand_path(file)}"
        new(*lines.split("\n").map { |line| Regexp.new(line) })
      end
    rescue => ex
      raise ConfigurationError.new,
        "Failed to load filter configuration file: #{file} - #{ex.message}"
    end

    def initialize(*accept_regexes)
      @accept_regexes = Set.new(accept_regexes)
    end

    def include?(line)
      to_proc.call(line)
    end

    def to_proc
      @proc ||= Proc.new { |line| !!(accept_regexes.find { |regex| line =~ regex }) }
    end

    def to_s
      "#<#{self.class.name}:#{accept_regexes.to_a.inspect}>"
    end

    private

    def accept_regexes
      @accept_regexes.to_a.sort_by(&:inspect)
    end
  end
end
