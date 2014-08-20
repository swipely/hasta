# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/local_file_path'

describe Hasta::LocalStorage do
  subject { described_class.new(fog_storage) }

  before do
    Hasta.configure do |conf|
      @original_storage_root = conf.local_storage_root
      conf.local_storage_root = tmpdir
    end
  end

  after do
    FileUtils.rm_rf(tmpdir)
    Hasta.configure do |conf|
      conf.local_storage_root = @original_storage_root
    end
  end

  let(:fog_storage) {
    Fog::Storage.new(
      :provider => 'Local',
      :local_root => tmpdir,
      :endpoint => 'http://example.com'
    )
  }
  let(:tmpdir) { Dir.mktmpdir('hasta_local_storage_test') }

  describe '#files_for' do
    it_should_behave_like 'a storage service'
  end

  describe '#write' do
    let(:s3_uri) { Hasta::S3URI.new(bucket_name, path) }
    let(:bucket_name) { 'my-bucket' }
    let(:content) { "Hi\nBye\nWhy?\n" }
    let(:data_source) { StringIO.new(content) }

    let!(:result) { subject.write(s3_uri, data_source) }
    let(:local_file_path) { Hasta::LocalFilePath.for(result) }

    context 'given a directory uri' do
      let(:path) { 'path/to/files/' }
      let(:expected_uri) { s3_uri.append('part-00000') }

      it { expect(result).to eq(expected_uri) }
      it { expect(File.read(local_file_path)).to eq(content) }
    end

    context 'given a file uri' do
      let(:path) { 'path/to/files/file.txt' }
      let(:expected_uri) { s3_uri }

      it { expect(result).to eq(expected_uri) }
      it { expect(File.read(local_file_path)).to eq(content) }
    end
  end
end
