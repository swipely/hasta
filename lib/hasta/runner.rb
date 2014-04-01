# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/env'
require 'hasta/execution_context'

module Hasta
  # Runs a map/reduce job locally
  class Runner
    attr_reader :job_name

    def initialize(job_name, mapper, reducer = nil)
      @job_name = job_name
      @mapper = mapper
      @reducer = reducer
    end

    def run(data_sources, data_sink, ruby_files = [], env = Hasta::Env.new)
      Hasta.logger.debug "Starting Job: #{job_name}"
      ExecutionContext.new(ruby_files, env.setup).execute do
        if reducer
          reducer.reduce(mapper.map(data_sources).data_source, data_sink)
        else
          mapper.map(data_sources, data_sink)
        end
      end
    end

    private

    attr_reader :mapper, :reducer
  end
end
