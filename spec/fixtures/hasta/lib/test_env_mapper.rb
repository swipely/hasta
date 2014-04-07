#!/usr/bin/env ruby

# Copyright Swipely, Inc.  All rights reserved.

class TestEnvMapper
  def map(line)
    line
  end
end

if __FILE__ == $0
  mapper = TestEnvMapper.new

  prefix = ENV['LINE_PREFIX']
  ARGF.each_line do |line|
    if mapped_line = mapper.map(line.strip)
      puts [prefix, mapped_line].join
    end
  end
end
