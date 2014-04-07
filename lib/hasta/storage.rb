# Copyright Swipely, Inc.  All rights reserved.

require 'hasta/s3_file'

module Hasta
  # Common file storage methods used by the local and S3 storage providers
  module Storage
    def initialize(fog_storage)
      @fog_storage = fog_storage
    end

    def exists?(s3_uri)
      if s3_uri.file?
        !!fog_file(s3_uri)
      elsif s3_bucket = bucket(s3_uri)
        !fog_files(s3_bucket, s3_uri).empty?
      end
    end

    def files_for(s3_uri)
      if s3_uri.file?
        [s3_file!(s3_uri)]
      else
        s3_files(bucket!(s3_uri), s3_uri)
      end
    end

    private

    attr_reader :fog_storage

    def bucket(s3_uri)
      fog_storage.directories.get(s3_uri.bucket)
    end

    def s3_file!(s3_uri)
      S3File.wrap(fog_file!(s3_uri))
    end

    def s3_files(bucket, s3_uri)
      fog_files(bucket, s3_uri).map { |fog_file| S3File.wrap(fog_file) }
    end

    def fog_file(s3_uri)
      (s3_bucket = bucket(s3_uri)) && s3_bucket.files.get(s3_uri.path)
    end

    def bucket!(s3_uri)
      bang!(s3_uri) { bucket(s3_uri) }
    end

    def fog_file!(s3_uri)
      bang!(s3_uri) { fog_file(s3_uri) }
    end

    def create_bucket(bucket_name)
      fog_storage.directories.create(:key => bucket_name)
    end

    def create_file(bucket, key, content)
      bucket.files.create(:body => content, :key => key)
    end

    def file_s3_uri(file, path=file.key)
      S3URI.new(file.directory.key, path)
    end

    def bang!(s3_uri)
      yield.tap do |result|
        raise NonExistentPath.new(s3_uri) unless result
      end
    end
  end
end
