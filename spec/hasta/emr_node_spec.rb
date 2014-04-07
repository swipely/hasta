# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/emr_node'

describe Hasta::EmrNode do
  subject { described_class.from_json(emr_node_json, scheduled_start_time) }

  let(:emr_node_json) {
    JSON.parse(File.read('spec/fixtures/hasta/json/emr_node.json'))
  }
  let(:scheduled_start_time) { Time.parse('2014-03-28T19:50:39Z') }

  let(:exp_input_paths) { ['s3n://data-bucket/path/to/data/2014-03-28_195039/input1/'] }
  let(:exp_output_path) { 's3://data-bucket/path/to/data/2014-03-28_195039/output/' }

  let(:exp_cache_files) {
    {
      'mappings.yml' => 's3://data-bucket/path/to/mappings.yml',
      'ignored.yml' => 's3://data-bucket/path/to/ignored.yml',
    }
  }

  it { expect(subject.id).to eq('EMRJob1') }
  it { expect(subject.input_paths).to eq(exp_input_paths) }
  it { expect(subject.output_path).to eq(exp_output_path) }
  it { expect(subject.mapper).to eq('cat') }
  it { expect(subject.reducer).to eq('s3n://steps-bucket/path/to/reducer.rb') }
  it { expect(subject.cache_files).to eq(exp_cache_files) }
  it { expect(subject.env).to eq({ 'API_KEY' => '123456', 'ENVIRONMENT_NAME' => 'uat' }) }
end
