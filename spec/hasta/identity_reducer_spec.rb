# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/identity_reducer'
require 'hasta/execution_context'

describe Hasta::IdentityReducer do
  describe '#reduce' do
    subject { described_class }

    let(:sink) { Hasta::InMemoryDataSink.new }
    let(:lines) { ["Key1\tFirst\n", "Key2\tSecond\n", "Key3\tThird\n"] }
    let(:exp_lines) { lines.map(&:rstrip) }
    let(:source) { Hasta::InMemoryDataSource.new(lines) }
    let(:context) { double(Hasta::ExecutionContext) }

    it { expect(subject.reduce(context, source, sink).data_source.to_a).to eq(exp_lines) }
  end
end
