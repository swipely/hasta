# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/combined_data_source'
require 'hasta/in_memory_data_source'

describe Hasta::CombinedDataSource do
  subject { described_class.new(sources) }

  let(:sources) {
    source_lines.each_with_index.map { |lines, i|
      Hasta::InMemoryDataSource.new(lines, "Source ##{i}")
    }
  }
  let(:source_lines) { [
    ['First'],
    ['Second', 'Third', 'Fourth'],
    ['Fifth', 'Sixth'],
  ] }

  it { expect(subject.each_line.to_a).to eq(source_lines.flatten) }
  it { expect(subject.to_a).to eq(source_lines.flatten) }
  it { expect(subject.name).to eq("Source #0, Source #1, Source #2") }
end
