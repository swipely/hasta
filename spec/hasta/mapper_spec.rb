# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/mapper'

describe Hasta::Mapper do
  let(:mapper) { double('Mapper') }

  describe '#map' do
    subject { described_class.new(mapper_file) }

    before do
      Hasta::MaterializeClass.
        should_receive(:from_file).
        with(mapper_file).
        and_return(mapper)
    end

    let(:mapper_file) { 'my_mapper.rb' }
    let(:input_source) { StringIO.new(input_lines.join("\n")) }
    let(:input_sources) { [input_source] }
    let(:input_lines) { ['One', 'Two', 'Three', 'Four'] }
    let(:output_lines) { input_lines }

    let(:sink) { Hasta::InMemoryDataSink.new }

    it 'writes all of the mapped lines to the sink' do
      input_lines.each do |line|
        mapper.should_receive(:map).ordered.with(line)
      end

      expect(subject.map(input_sources, sink)).to eq(sink)
    end
  end
end
