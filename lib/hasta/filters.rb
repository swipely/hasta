# Copyright Swipely, Inc.  All rights reserved.

require 'yaml'

require 'hasta/s3_uri'

module Hasta
  # Defines filters for different S3 path prefixes
  class Filters
    def self.from_file(file)
      Hasta.logger.debug "Loading data filter file: #{File.expand_path(file)}"
      new(YAML.load_file(file))
    rescue => ex
      raise ConfigurationError.new,
        "Failed to load filter configuration file: #{file} - #{ex.message}"
    end

    def initialize(filters)
      @filters = filters.map { |s3_uri, regexes|
        [S3URI.parse(s3_uri), Filter.new(*regexes.map { |regex| Regexp.new(regex) }) ]
      }.sort_by { |s3_uri, regexes| s3_uri.depth }.reverse
    end

    def for_s3_uri(target_s3_uri)
      if match = filters.find { |s3_uri, filter| target_s3_uri.start_with?(s3_uri) }
        match[1]
      end
    end

    private

    attr_reader :filters
  end
end
