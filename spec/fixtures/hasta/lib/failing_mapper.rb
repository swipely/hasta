#!/usr/bin/env ruby

# Copyright Swipely, Inc.  All rights reserved.

class FailingMapper
  def map(line)
    raise 'Failure'
  end
end

if __FILE__ == $0
  mapper = FailingMapper.new

  ARGF.each_line do |line|
    if mapped_line = mapper.map(line.strip)
      puts mapped_line
    end
  end
end
