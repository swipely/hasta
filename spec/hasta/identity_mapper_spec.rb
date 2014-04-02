# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/identity_mapper'
require 'hasta/in_memory_data_sink'
require 'hasta/in_memory_data_source'

describe Hasta::IdentityMapper do
  describe '#map' do
    subject { described_class }

    let(:sink) { Hasta::InMemoryDataSink.new }
    let(:lines) { [['First'], ['Second', 'Third']] }
    let(:sources) { lines.map { |source_lines| Hasta::InMemoryDataSource.new(source_lines) } }

    it { expect(subject.map(sources, sink).data_source.to_a).to eq(lines.flatten) }
  end
end