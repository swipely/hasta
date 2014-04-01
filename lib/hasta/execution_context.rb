# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/s3_data_sink'

module Hasta
  # Executes each local EMR job in isolation
  class ExecutionContext
    def initialize(ruby_files = [], env = {})
      @ruby_files = ruby_files
      @env = env
    end

    def execute
      reader, writer = IO.pipe

      pid = fork do
        reader.close
        execute_job(writer) { yield }
      end

      writer.close
      process_result(pid, reader)
    end

    private

    attr_reader :ruby_files, :env

    def execute_job(writer)
      begin
        setup_environment

        data_sink = yield

        writer.puts 0
        writer.puts data_sink.s3_uri
      rescue => ex
        Hasta.logger.error "#{ex.message}\n#{ex.backtrace.join("\n")}"
        writer.puts -1
        writer.puts "#{ex.class.name}: #{ex.message}"
      end
    end

    def setup_environment
      env.each do |name, value|
        ENV[name] = value
      end

      ruby_files.map { |file| File.dirname(file) }.uniq.each do |dir|
        load_path_dir = File.expand_path(dir)
        Hasta.logger.debug "Adding directory: #{load_path_dir} to $LOAD_PATH"
        $LOAD_PATH.unshift(load_path_dir)
      end
    end

    def process_result(pid, reader)
      status = reader.gets.to_i
      if status == 0
        result_uri = reader.gets.strip

        Process.wait(pid)
        result_uri
      else
        message = reader.gets
        Process.wait(pid)
        raise ExecutionError, message
      end
    end
  end
end
