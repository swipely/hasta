# Copyright Swipely, Inc.  All rights reserved.

require 'delegate'
require 'digest/md5'

module Hasta
  # An S3File delegate that drops filtered lines
  class FilteredS3File < SimpleDelegator
    def initialize(s3_file, filter)
      super(s3_file)
      @filter = filter
    end

    def body
      each_line.to_a.join
    end

    def fingerprint
      @fingerprint ||= Digest::MD5.hexdigest("#{__getobj__.fingerprint}_#{filter.to_s}")
    end

    def each_line
      return enum_for(:each_line) unless block_given?

      __getobj__.each_line do |line|
        yield line if filter.include?(line)
      end
    end

    private

    attr_reader :filter
  end
end
