# Copyright Swipely, Inc.  All rights reserved.

require 'forwardable'

module Hasta
  # Hasta's interface to the File objects returned by Fog
  class S3File
    extend Forwardable

    def_delegators :s3_file, :key, :body

    def self.wrap_files(s3_files)
      s3_files.map { |s3_file| wrap(s3_file) }
    end

    def self.wrap(s3_file)
      if self === s3_file
        s3_file
      elsif s3_file.nil?
        nil
      else
        new(s3_file)
      end
    end

    def initialize(s3_file)
      @s3_file = s3_file
    end

    def s3_uri
      @s3_uri ||= S3URI.new(s3_file.directory.key, key)
    end

    def fingerprint
      @fingerprint ||= if s3_file.respond_to? :etag
        s3_file.etag
      else
        Digest::MD5.hexdigest(body)
      end
    end

    def remote?
      !(Fog::Storage::Local::File === s3_file)
    end

    def each_line
      return enum_for(:each_line) unless block_given?

      StringIO.new(s3_file.body).each_line { |line| yield line }
    end

    private

    attr_reader :s3_file
  end
end
