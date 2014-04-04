# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/identity_mapper'
require 'hasta/execution_context'
require 'hasta/in_memory_data_sink'
require 'hasta/in_memory_data_source'

describe Hasta::IdentityMapper do
  describe '#map' do
    subject { described_class }

    let(:sink) { Hasta::InMemoryDataSink.new }
    let(:lines) { [["First\n"], ["Second\n", "Third\n"]] }
    let(:exp_lines) { lines.flatten.map(&:rstrip) }
    let(:sources) { lines.map { |source_lines| Hasta::InMemoryDataSource.new(source_lines) } }
    let(:context) { double(Hasta::ExecutionContext) }

    it { expect(subject.map(context, sources, sink).data_source.to_a).to eq(exp_lines) }
  end
end
