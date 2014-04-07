# Copyright Swipely, Inc.  All rights reserved.

require 'fog'
require 'logger'

require 'hasta/local_storage'
require 'hasta/s3_storage'
require 'hasta/combined_storage'

module Hasta
  # Global configuration settings
  class Configuration
    attr_accessor :project_root
    attr_writer :local_storage_root, :project_steps, :logger

    def local_storage_root
      @local_storage_root ||= '~/fog'
    end

    def project_steps
      @project_steps ||= 'steps'
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def project_steps_dir
      File.join(project_root, project_steps)
    end

    def combined_storage
      @combined_storage ||= CombinedStorage.new(
        S3Storage.new(fog_s3_storage),
        LocalStorage.new(fog_local_storage)
      )
    end

    private

    def fog_s3_storage
      # Use FOG_CREDENTIAL env variable to control AWS credentials
      @fog_s3_storage ||= Fog::Storage::AWS.new
    end

    def fog_local_storage
      @fog_local_storage ||= Fog::Storage.new(
        :provider => 'Local',
        :local_root => local_storage_root,
        :endpoint => 'http://example.com'
      )
    end
  end
end
