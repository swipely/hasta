# Copyright Swipely, Inc.  All rights reserved.

require 'fog'
require 'logger'

require 'hasta/local_storage'
require 'hasta/s3_storage'
require 'hasta/combined_storage'
require 'hasta/filter'
require 'hasta/resolve_cached_s3_file'
require 'hasta/resolve_filtered_s3_file'

module Hasta
  # Global configuration settings
  class Configuration
    attr_accessor :project_root
    attr_writer :local_storage_root, :cache_storage_root, :project_steps, :logger, :filters

    def local_storage_root
      @local_storage_root ||= '~/fog'
    end

    def cache_storage_root
      @cache_storage_root ||= '~/.hasta'
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
        S3Storage.new(fog_s3_storage, resolver),
        LocalStorage.new(fog_local_storage, resolver)
      )
    end

    def filters
      unless @filters || ENV['HASTA_DATA_FILTERING'] == 'OFF'
        filter_file = ENV['HASTA_DATA_FILTER_FILE'] || 'filter_config.yml'
        @filters ||= Filters.from_file(filter_file)
      end

      @filters
    end

    private

    def fog_s3_storage
      # Use FOG_CREDENTIAL env variable to control AWS credentials
      @fog_s3_storage ||= Fog::Storage::AWS.new
    end

    def fog_local_storage
      @fog_local_storage ||= local_fog(local_storage_root)
    end

    def fog_cache_storage
      @fog_cache_storage ||= local_fog(cache_storage_root)
    end

    def local_fog(local_root)
      Fog::Storage.new(
        :provider => 'Local',
        :local_root => local_root,
        :endpoint => 'http://example.com'
      )
    end

    def resolver
      if filters
        ResolveCachedS3File.new(
          S3FileCache.new(fog_cache_storage), ResolveFilteredS3File.new(filters)
        )
      else
        Hasta::Storage::ResolveS3File
      end
    end
  end
end
