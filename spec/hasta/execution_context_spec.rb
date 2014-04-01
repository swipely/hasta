# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/execution_context'
require 'hasta/s3_data_source'

describe Hasta::ExecutionContext do
  describe '#execute' do
    before do
      lines.each { |line| sink << line }
    end

    let(:output_s3_uri) { Hasta::S3URI.parse('s3://data-bucket/path/to/output/') }
    let(:sink) { Hasta::S3DataSink.new(output_s3_uri) }
    let(:lines) { %w[First Second Third] }
    let(:exp_lines) { lines.join("\n,").split(',') }
    let(:block) { proc { sink.close } }
    let(:result_data_source) {
      Hasta::S3DataSource.new(Hasta::S3URI.parse(subject.execute(&block)))
    }

    it 'returns the execution results' do
      expect(result_data_source.to_a).to eq(exp_lines)
    end

    context 'given env variables' do
      subject { described_class.new([], env) }

      let(:env) { { 'API_KEY' => '123456' } }
      let(:block) {
        proc {
          raise 'Error' unless ENV['API_KEY'] == '123456'
          sink
        }
      }

      it 'returns the execution results' do
        expect(result_data_source.to_a).to eq(exp_lines)
      end

      it 'does not set the ENV of the parent process' do
        expect(ENV['API_KEY']).to be_nil
      end
    end

    context 'given additional Ruby files' do
      subject { described_class.new(files) }

      let(:files) { [file] }
      let(:file) { "#{File.dirname(__FILE__)}/../fixtures/hasta/lib/types.rb" }
      let(:dir) { File.expand_path(File.dirname(file)) }
      let(:block) {
        proc {
          require 'types'
          klass = Object.const_get('Thing')
          sink
        }
      }

      it 'returns the execution results' do
        expect(result_data_source.to_a).to eq(exp_lines)
      end

      it 'does not affect the $LOAD_PATH of the parent process' do
        expect($LOAD_PATH).to_not include(dir)
      end
    end

    context 'given job failure' do
      let(:block) {
        proc { klass = Object.const_get('UndefinedClass') }
      }

      it 'raises' do
        expect { subject.execute(&block) }.to raise_error(Hasta::ExecutionError)
      end
    end
  end
end
