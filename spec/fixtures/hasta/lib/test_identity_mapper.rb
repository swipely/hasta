#!/usr/bin/env ruby

# Copyright Swipely, Inc.  All rights reserved.

class TestIdentityMapper
  def map(line)
    line
  end
end

if __FILE__ == $0
  mapper = TestIdentityMapper.new

  $stderr.puts "This is an error message"
  ARGF.each_line do |line|
    if mapped_line = mapper.map(line.strip)
      puts mapped_line
    end
  end
end
