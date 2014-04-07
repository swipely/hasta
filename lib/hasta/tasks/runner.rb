# Copyright Swipely, Inc.  All rights reserved.


require 'rake'
require 'rake/tasklib'
require 'hasta'

require 'hasta/emr_job_definition'
require 'hasta/runner'

module Hasta
  module Tasks
    # Rakes task that runs a local test of an EMR job
    class Runner < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of task.
      #
      # default:
      #   :runner
      attr_accessor :name

      # Path to the AWS Data Pipeline definition file
      attr_accessor :definition_file

      # The Scheduled Start Time to use when evaluating the definition
      #
      # default:
      #  Time.now
      attr_accessor :scheduled_start_time

      # The id of the EMR job to perform
      attr_accessor :job_id

      # The root directory of the project containing the EMR code that is being tested
      attr_accessor :project_root

      # Use verbose output. If this is set to true, the task will print the
      # local and remote paths of each step file it uploads to S3.
      #
      # default:
      #   true
      attr_accessor :verbose

      def initialize(*args, &task_block)
        setup_ivars(args)

        desc "Runs the specified EMR job"
        task name, [:job_id, :scheduled_start_time] do |_, task_args|
          RakeFileUtils.send(:verbose, verbose) do
            if task_block
              task_block.call(*[self, task_args].slice(0, task_block.arity))
            end

            run_task verbose
          end
        end
      end

      def setup_ivars(args)
        @name = args.shift || :runner
        @verbose = true
        @path = "definitions"
        @scheduled_start_time = Time.now
      end

      def run_task(verbose)
        Hasta.configure do |config|
          config.project_root = project_root
        end

        definition = Hasta::EmrJobDefinition.load(definition_file, job_id, scheduled_start_time)
        runner = Hasta::Runner.new(definition.id, definition.mapper, definition.reducer)

        result = runner.run(
          definition.data_sources,
          definition.data_sink,
          definition.ruby_files,
          definition.env
        )
      end
    end
  end
end