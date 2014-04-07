# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/sorted_data_source'

describe Hasta::SortedDataSource do
  describe '#each_line' do
    subject { described_class.new(data_source) }

    let(:data_source) { [3,2] }
    let(:sorted) { [2,3] }

    context 'given a block' do
      it { expect { |block| subject.each_line(&block) }.to yield_successive_args(*sorted) }
    end

    context 'given no block' do
      it { expect(subject.each_line.to_a).to eq(sorted) }
    end
  end
end
