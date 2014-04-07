# Copyright Swipely, Inc.  All rights reserved.

require 'open3'

require 'hasta/s3_data_sink'

module Hasta
  # Executes each local EMR job in isolation
  class ExecutionContext
    # A Subprocess
    class Subprocess
      attr_reader :stdin, :stdout, :stderr

      def initialize(ruby_files, env)
        @ruby_files = ruby_files
        @env = env
      end

      def start(source_file, data_source, data_sink)
        Open3.popen3(*cmd_line(source_file)) do |stdin, stdout, stderr, wait_thr|
          @stdin, @stdout, @stderr, @wait_thr = stdin, stdout, stderr, wait_thr

          yield self

          if (exit_code = wait_thr.value.exitstatus) != 0
            raise ExecutionError, "#{source_file} exited with non-zero status: #{exit_code}"
          end
        end
      end

      private

      attr_reader :source_file, :env, :ruby_files

      def cmd_line(source_file)
        [env, ruby_exe_path] + load_path + [source_file]
      end

      def ruby_exe_path
        File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
      end

      def load_path
        ruby_files.
          map { |file| File.expand_path(File.dirname(file)) }.
          uniq.
          map { |path| ['-I', path] }.
          flatten
      end
    end

    def initialize(ruby_files = [], env = {})
      @sub_process = Subprocess.new(ruby_files, env)
    end

    def execute(source_file, data_source, data_sink)
      sub_process.start(source_file, data_source, data_sink) do |sub_process|
        [
          stream_input(data_source, sub_process.stdin),
          stream_output(sub_process.stdout) { |line| data_sink << line },
          stream_output(sub_process.stderr) { |line| Hasta.logger.error line },
        ].each(&:join)
      end

      data_sink.close
    end

    private

    attr_reader :sub_process

    def stream_input(data_source, io)
      Thread.new do
        data_source.each_line do |line|
          io.puts line
        end

        io.close_write
      end
    end

    def stream_output(io)
      Thread.new do
        StringIO.new(io.read).each_line do |line|
          yield line.rstrip
        end
      end
    end
  end
end
