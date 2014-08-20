# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/interpolate_string'

module Hasta
  # Models the Amazon Data Pipeline configuration details for the EMR job that is being tested
  class EmrNode
    class << self
      def from_json(json, scheduled_start_time = Time.now)
        command_line = parse_step_line(json['step'])

        new(
          :id => json['id'],
          :input_paths => command_line['input'],
          :output_path => command_line['output'].first,
          :mapper => command_line['mapper'].first,
          :reducer => command_line['reducer'].first,
          :cache_files => command_line['cacheFile'],
          :env => command_line['cmdenv'],
          :scheduled_start_time => scheduled_start_time
        )
      end

      private

      # Parses the 'step' attribute of an EMR configuration into a Hash
      # Sample step line:
      #   "/home/hadoop/contrib/streaming/hadoop-streaming.jar,
      #    -input,s3n://data-bucket/input1/,
      #    -output,s3://data-bucket/output/,
      #    -mapper,cat,
      #    -reducer,s3n://steps-bucket/path/to/reducer.rb,
      #    -cacheFile,s3://data-bucket/path/to/mappings.yml#mappings.yml,
      #    -cacheFile,s3://data-bucket/path/to/ignored.yml#ignored.yml,
      #    -cmdenv,API_KEY=123456,
      #    -cmdenv,ENVIRONMENT_NAME=uat"
      #
      # Sample output:
      #   {
      #     "input" => ["s3n://data-bucket/input1/"],
      #     "output"=> ["s3://data-bucket/output/"],
      #     "mapper => ["cat"],
      #     "reducer" => ["s3n://steps-bucket/path/to/reducer.rb"],
      #     "cacheFile" => ["s3://data-bucket/path/to/mappings.yml#mappings.yml",
      #       "s3://data-bucket/path/to/ignored.yml#ignored.yml"],
      #     "cmdenv" => ["API_KEY=123456", "ENVIRONMENT_NAME=uat"]
      #   }
      #
      def parse_step_line(step)
        parsed = Hash.new { |h, k| h[k] = [] }
        step.
          split(',-').
          drop(1).
          map { |value| i = value.index(','); [value[0...i], value[i+1..-1]] }.
          each do |switch, arg|
            parsed[switch] << arg
          end

        parsed
      end
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def id
      attributes[:id]
    end

    def input_paths
      @input_path ||= attributes[:input_paths].map { |path| interpolate(path) }
    end

    def output_path
      @output_path ||= interpolate(attributes[:output_path])
    end

    def mapper
      attributes[:mapper]
    end

    def reducer
      attributes[:reducer]
    end

    def cache_files
      @cache_files ||= Hash[attributes[:cache_files].map { |value| interpolate(value).split('#').reverse }]
    end

    def env
      @env ||= Hash[attributes[:env].map { |value| value.split('=') }]
    end

    private

    attr_reader :attributes

    def interpolate(path)
      InterpolateString.evaluate(path, 'scheduledStartTime' => attributes[:scheduled_start_time])
    end
  end
end
