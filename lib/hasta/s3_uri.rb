# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Represents a URI to a file or directory on S3
  class S3URI
    attr_reader :bucket, :path

    def self.parse(uri)
      if match = /\As3n?:\/\/([^\/]+?)(\/.*)?\z/.match(uri)
        canonical_path = match[2] && match[2][1..-1]
        new(match[1], canonical_path)
      else
        raise ArgumentError, "Invalid S3 URI: #{uri}"
      end
    end

    def initialize(bucket, path)
      @bucket = bucket
      @path = path
    end

    def directory?
      path.nil? || path.end_with?('/')
    end

    def file?
      !directory?
    end

    def basename
      if path
        path.split('/').last
      else
        ''
      end
    end

    def depth
      slashes = (path && path.chars.count { |ch| ch == '/' }) || 0
      if path.nil?
        1
      elsif directory?
        1 + slashes
      else
        2 + slashes
      end
    end

    def start_with?(s3_uri)
      return true if self == s3_uri
      return false if s3_uri.file?

      (bucket == s3_uri.bucket) && (s3_uri.path.nil? || path.start_with?(s3_uri.path))
    end

    def parent
      if path.nil?
        nil
      else
        elements = path.split('/')
        self.class.new(bucket, "#{elements.take(elements.length - 1).join('/')}/")
      end
    end

    def append(append_path)
      raise ArgumentError, "Cannot append to a file path: #{self}" if file?
      self.class.new(bucket, File.join(path, append_path))
    end

    def ==(other)
      self.class === other && (self.bucket == other.bucket && self.path == other.path)
    end

    def to_s
      ["s3:/", bucket, path].compact.join('/')
    end
  end
end
