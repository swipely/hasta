# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/reducer'
require 'hasta/in_memory_data_source'

describe Hasta::Reducer do
  describe '#reduce' do
    subject { described_class.new(reducer_file) }

    let(:reducer_file) { 'spec/fixtures/hasta/lib/unconventional_reducer.rb' }
    let(:input_source) { Hasta::InMemoryDataSource.new(input_lines) }
    let(:input_lines) { ["Small", "Medium", "Large"] }
    let(:sorted_lines) { ["Large", "Medium", "Small"] }
    let(:exp_lines) { sorted_lines.map { |line| "#{line}\n"} }
    let(:context) { Hasta::ExecutionContext.new }

    let(:sink) { Hasta::InMemoryDataSink.new }

    it 'reducers over all of the input lines in sorted order' do
      expect(subject.reduce(context, input_source, sink)).to eq(sink)
      expect(sink.data_source.to_a).to eq(exp_lines)
    end
  end
end
