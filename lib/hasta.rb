# Copyright Swipely, Inc.  All rights reserved.

require "hasta/version"
require "hasta/configuration"

require "forwardable"

# The HAdoop Streaming Test hArness
module Hasta
  extend self
  extend Forwardable

  Error = Class.new(StandardError)
  NonExistentPath = Class.new(Error)
  ClassLoadError = Class.new(Error)
  ExecutionError = Class.new(Error)

  DELEGATED_ATTRS = [
    :combined_storage,
    :local_storage_root,
    :logger,
    :project_root,
    :project_steps,
    :sort_by,
  ]

  def_delegators :config, *DELEGATED_ATTRS

  def configure
    yield config
  end

  private

  def config
    @config ||= Configuration.new
  end
end
