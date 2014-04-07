# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Interpolates scheduled start time expressions in S3 path strings
  class InterpolateString
    INTERPOLATE_PATTERN = /\#\{format\(@scheduledStartTime,'(.*?)'\)\}/

    PATTERN_CONVERSIONS = {
      'YYYY' => '%Y',
      'MM' => '%m',
      'dd' => '%d',
      'HH' => '%H',
      'mm' => '%M',
      'ss' => '%S',
    }

    def self.evaluate(pattern, context)
      new(pattern).evaluate(context)
    end

    def initialize(pattern)
      @pattern = pattern
    end

    def evaluate(context)
      pattern.gsub(INTERPOLATE_PATTERN) do |match|
        format(context, Regexp.last_match[1])
      end
    end

    private

    attr_reader :pattern

    def format(context, pattern)
      context['scheduledStartTime'].strftime(convert_pattern(pattern))
    end

    def convert_pattern(pattern)
      PATTERN_CONVERSIONS.inject(pattern) { |converted_pattern, (pipeline_pattern, ruby_pattern)|
        converted_pattern.gsub(pipeline_pattern, ruby_pattern)
      }
    end
  end
end
