# Copyright Swipely, Inc.  All rights reserved.

require 'forwardable'
require 'json'

require 'hasta/emr_node'
require 'hasta/env'
require 'hasta/identity_mapper'
require 'hasta/mapper'
require 'hasta/reducer'
require 'hasta/identity_reducer'
require 'hasta/s3_data_source'
require 'hasta/s3_uri'
require 'hasta/s3_data_sink'

module Hasta
  # Defines the EMR job that is being tested
  class EmrJobDefinition
    extend Forwardable

    def self.load(file_path, id, scheduled_start_time = Time.now)
      emr_node = JSON.parse(File.read(file_path))['objects'].find { |node|
        node['type'] == 'EmrActivity' && node['id'] == id
      }

      raise ArgumentError, "No EmrActivity for id: #{id} in file: #{file_path}" unless emr_node
      new(EmrNode.from_json(emr_node, scheduled_start_time))
    end

    def_delegators :emr_node, :id

    def initialize(emr_node)
      @emr_node = emr_node
    end

    def input_paths
      @input_paths ||= emr_node.input_paths.map { |path| S3URI.parse(path) }
    end

    def output_path
      @output_path ||= S3URI.parse(emr_node.output_path)
    end

    def env
      @env ||= Env.new(
        emr_node.env,
        Hash[
          emr_node.
            cache_files.
            reject { |tag, uri| uri.end_with?('.rb') }.
            map { |tag, uri| ["#{tag.split('.').first.upcase}_FILE_PATH", S3URI.parse(uri)] }
        ]
      )
    end

    def ruby_files
      @ruby_files ||= emr_node.
        cache_files.
        values.
        select { |uri| uri.end_with?('.rb') }.
        map { |uri| local_path_to_step_file(S3URI.parse(uri)) }
    end

    def mapper
      @mapper ||= parse_mapper(emr_node.mapper)
    end

    def reducer
      @reducer ||= parse_reducer(emr_node.reducer)
    end

    def data_sources
      @data_sources ||= input_paths.map { |path| S3DataSource.new(path) }
    end

    def data_sink
      @data_sink ||= S3DataSink.new(output_path)
    end

    private

    attr_reader :emr_node

    def local_path_to_step_file(s3_uri)
      File.join(Hasta.project_root, Hasta.project_steps, s3_uri.basename)
    end

    def parse_mapper(mapper_command)
      if %w[cat org.apache.hadoop.mapred.lib.IdentityMapper].include?(mapper_command)
        IdentityMapper
      else
        Mapper.new(local_path_to_step_file(S3URI.parse(mapper_command)))
      end
    end

    def parse_reducer(reducer_command)
      if %w[cat org.apache.hadoop.mapred.lib.IdentityReducer].include?(reducer_command)
        IdentityReducer
      else
        Reducer.new(local_path_to_step_file(S3URI.parse(reducer_command)))
      end
    end
  end
end
