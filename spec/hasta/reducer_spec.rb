# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/reducer'

describe Hasta::Reducer do
  let(:reducer) { double('Reducer')  }

  describe '#reduce' do
    subject { described_class.new(reducer_file) }

    before do
      Hasta::MaterializeClass.
        should_receive(:from_file).
        with(reducer_file).
        and_return(reducer)
    end

    let(:reducer_file) { 'my_reducer.rb' }
    let(:input_source) { StringIO.new(input_lines.join("\n")) }
    let(:input_lines) { ["Small", "Medium", "Large"] }
    let(:sorted_lines) { ["Large", "Medium", "Small"] }

    let(:sink) { Hasta::InMemoryDataSink.new }

    it 'reducers over all of the input lines in sorted order' do
      sorted_lines.each do |line|
        reducer.should_receive(:reduce).ordered.with(line)
      end

      expect(subject.reduce(input_source, sink)).to eq(sink)
    end
  end
end
