#!/usr/bin/env ruby

# Copyright Swipely, Inc.  All rights reserved.

require 'types'

class TestTypesMapper
  def map(line)
    line
  end
end

if __FILE__ == $0
  mapper = TestTypesMapper.new

  ARGF.each_line do |line|
    if mapped_line = mapper.map(line.strip)
      puts Thing.new(mapped_line).line
    end
  end
end
