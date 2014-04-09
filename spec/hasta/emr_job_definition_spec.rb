require 'spec_helper'

require 'hasta/emr_job_definition'

describe Hasta::EmrJobDefinition do
  shared_context 'with a filter defined' do
    before do
      Hasta.configure do |config|
        config.filters = Hasta::Filters.new({ 's3://my-bucket' => ['.*'] })
      end
    end

    after do
      Hasta.configure do |config|
        config.filters = nil
      end
    end
  end

  describe '.load' do
    subject { described_class.load(file_path, id) }

    include_context 'with a filter defined'

    let(:file_path) { 'spec/fixtures/hasta/json/pipeline_definition.json' }

    let(:id) { 'EMRJob1' }
    let(:exp_input_paths) {
      [
        Hasta::S3URI.parse('s3://data-bucket/path/to/data/dir1/'),
        Hasta::S3URI.parse('s3://data-bucket/path/to/data/dir2/'),
        Hasta::S3URI.parse('s3://data-bucket/path/to/data/file.csv'),
      ]
    }
    let(:exp_output_path) { Hasta::S3URI.parse('s3://data-bucket/path/to_data/results/') }
    let(:env_vars) { { 'API_KEY' => '123456' } }
    let(:env_files) {
      { 'NOTES_FILE_PATH' => Hasta::S3URI.parse('s3://data-bucket/path/to/data/notes.yml') }
    }

    it { expect(subject.id).to eq(id) }
    it { expect(subject.input_paths).to include(*exp_input_paths) }
    it { expect(subject.output_path).to eq(exp_output_path) }
    it { expect(subject.env.variables).to eq(env_vars) }
    it { expect(subject.env.files).to eq(env_files) }
  end

  describe '#ruby_files' do
    subject { described_class.new(emr_node) }

    before do
      Hasta.configure do |config|
        config.project_root = '/home/user/project'
      end
    end

    after do
      Hasta.configure do |config|
        config.project_root = nil
      end
    end

    let(:emr_node) { Hasta::EmrNode.new(:cache_files => cache_files) }
    let(:cache_files) {
      [
        's3n://steps-bucket/path/to/constants.rb#constants.rb',
        's3://data-bucket/path/to/mappings.yml#mappings.yml',
      ]
    }

    let(:ruby_files) {
      [ "#{Hasta.project_root}/#{Hasta.project_steps}/constants.rb" ]
    }

    it { expect(subject.ruby_files).to eq(ruby_files) }
  end

  describe '#mapper' do
    subject { described_class.new(emr_node) }

    let(:emr_node) { Hasta::EmrNode.new(:mapper => mapper_command) }

    let(:mapper) { subject.mapper }

    context 'given cat as the mapper command' do
      let(:mapper_command) { 'cat' }

      it { expect(mapper).to be(Hasta::IdentityMapper) }
    end

    context 'given the IdentityMapper' do
      let(:mapper_command) { 'org.apache.hadoop.mapred.lib.IdentityMapper' }

      it { expect(mapper).to be(Hasta::IdentityMapper) }
    end

    context 'given a Ruby mapper' do
      before do
        Hasta.configure do |config|
          config.project_root = '/home/user/project'
        end
      end

      after do
        Hasta.configure do |config|
          config.project_root = nil
        end
      end

      let(:mapper_command) { 's3n://steps-bucket/path/to/mapper.rb' }
      let(:exp_mapper_file) { "#{Hasta.project_root}/#{Hasta.project_steps}/mapper.rb" }

      it { expect(mapper.mapper_file).to eq(exp_mapper_file) }
    end
  end

  describe '#reducer' do
    subject { described_class.new(emr_node) }

    let(:emr_node) { Hasta::EmrNode.new(:reducer => reducer_command) }

    let(:reducer) { subject.reducer }

    context 'given cat as the reducer command' do
      let(:reducer_command) { 'cat' }

      it { expect(reducer).to be(Hasta::IdentityReducer) }
    end

    context 'given the IdentityReducer' do
      let(:reducer_command) { 'org.apache.hadoop.mapred.lib.IdentityReducer' }

      it { expect(reducer).to be(Hasta::IdentityReducer) }
    end

    context 'given a Ruby reducer' do
      before do
        Hasta.configure do |config|
          config.project_root = '/home/user/project'
        end
      end

      after do
        Hasta.configure do |config|
          config.project_root = nil
        end
      end

      let(:reducer_command) { 's3n://steps-bucket/path/to/reducer.rb' }
      let(:exp_reducer_file) { "#{Hasta.project_root}/#{Hasta.project_steps}/reducer.rb" }

      it { expect(reducer.reducer_file).to eq(exp_reducer_file) }
    end
  end

  describe '#env' do
    subject { described_class.new(emr_node) }

    include_context 'with a filter defined'

    let(:emr_node) { Hasta::EmrNode.new(:cache_files => cache_files, :env => env_vars) }
    let(:s3_uri) { Hasta::S3URI.parse('s3://data-bucket/path/to/database.yml') }
    let(:cache_files) { [ "#{s3_uri.to_s}#database.yml" ] }
    let(:env_vars) { [ "API_KEY=123456" ] }

    it { expect(subject.env.variables).to eq({ 'API_KEY' => '123456' }) }
    it { expect(subject.env.files).to eq({ 'DATABASE_FILE_PATH' => s3_uri }) }
  end

  describe '#data_sink' do
    subject { described_class.new(emr_node) }

    include_context 'with a filter defined'

    let(:emr_node) { Hasta::EmrNode.new(:output_path => output_path) }
    let(:output_path) { 's3://data-bucket/path/to/data/2014-03-31_192134/output/' }
    let(:s3_uri) { Hasta::S3URI.parse(output_path) }

    it { expect(subject.data_sink.s3_uri).to eq(s3_uri) }
  end
end
