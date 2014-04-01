#!/usr/bin/env ruby

class NoOpReducer
  def reduce(line)
    line
  end
end

if __FILE__ == $0
  reducer = NoOpReducer.new

  ARGF.each_line do |line|
    if line = reducer.reduce(line.strip)
      puts line
    end
  end
end
