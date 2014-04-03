# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/execution_context'
require 'hasta/s3_data_source'
require 'hasta/in_memory_data_sink'
require 'hasta/in_memory_data_source'

describe Hasta::ExecutionContext do
  describe '#execute' do
    let(:source_file) { 'spec/fixtures/hasta/lib/test_identity_mapper.rb' }
    let(:data_source) { Hasta::InMemoryDataSource.new(lines) }
    let(:data_sink) { Hasta::InMemoryDataSink.new }
    let(:lines) { %w[First Second Third] }
    let(:exp_lines) { lines.map { |line| "#{line}\n" } }
    let(:results) { subject.execute(source_file, data_source, data_sink).data_source }

    it 'returns the execution results' do
      expect(results.to_a).to eq(exp_lines)
    end

    context 'given env variables' do
      subject { described_class.new([], env) }

      let(:env) { { 'LINE_PREFIX' => prefix } }
      let(:prefix) { 'Copyright 2014 ' }
      let(:source_file) { 'spec/fixtures/hasta/lib/test_env_mapper.rb' }
      let(:exp_lines) { lines.map { |line| "#{prefix}#{line}\n" } }

      it 'returns the execution results' do
        expect(results.to_a).to eq(exp_lines)
      end

      it 'does not set the ENV of the parent process' do
        expect(ENV['LINE_PREFIX']).to be_nil
      end
    end

    context 'given additional Ruby files' do
      subject { described_class.new(files) }

      let(:files) { [file] }
      let(:file) { "#{File.dirname(__FILE__)}/../fixtures/hasta/lib/types.rb" }
      let(:dir) { File.expand_path(File.dirname(file)) }
      let(:source_file) { 'spec/fixtures/hasta/lib/test_types_mapper.rb' }

      it 'returns the execution results' do
        expect(results.to_a).to eq(exp_lines)
      end

      it 'does not affect the $LOAD_PATH of the parent process' do
        expect($LOAD_PATH).to_not include(dir)
      end
    end

    context 'given job failure' do
      let(:source_file) { 'spec/fixtures/hasta/lib/failing_mapper.rb' }

      it 'raises' do
        expect {
          subject.execute(source_file, data_source, data_sink)
        }.to raise_error(Hasta::ExecutionError)
      end
    end
  end
end
