# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/mapper'

describe Hasta::Mapper do
  let(:mapper_file) { 'spec/fixtures/hasta/lib/test_identity_mapper.rb' }

  describe '#map' do
    subject { described_class.new(mapper_file) }

    let(:input_source) { Hasta::InMemoryDataSource.new(input_lines, "Test Input") }
    let(:input_sources) { [input_source] }
    let(:input_lines) { ['One', 'Two', 'Three', 'Four'] }
    let(:output_lines) { input_lines }
    let(:context) { Hasta::ExecutionContext.new }

    let(:sink) { Hasta::InMemoryDataSink.new }

    it 'writes all of the mapped lines to the sink' do
      expect(subject.map(context, input_sources, sink)).to eq(sink)
      expect(sink.data_source.to_a).to eq(input_lines.map { |line| "#{line}\n" })
    end
  end
end
