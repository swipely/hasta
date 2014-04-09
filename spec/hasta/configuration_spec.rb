# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/in_memory_data_source'

describe Hasta::Configuration do
  describe '#filters' do
    subject { described_class.new }

    context 'given a custom path is specified' do
      before do
        ENV['HASTA_DATA_FILTER_FILE'] = 'spec/fixtures/hasta/filter_config.yml'
      end

      after do
        ENV.delete('HASTA_DATA_FILTER_FILE')
      end

      it { expect(subject.filters).to_not be_nil }

      context 'given filtering is disabled' do
        before do
          ENV['HASTA_DATA_FILTERING'] = 'OFF'

          subject.local_storage_root = local_storage_root
          subject.combined_storage.write(local_s3_uri, Hasta::InMemoryDataSource.new(["ABC\n"]))
        end

        after do
          ENV.delete('HASTA_DATA_FILTERING')
          FileUtils.rm_rf(local_storage_root)
        end

        let(:local_storage_root) { Dir.mktmpdir('config_test_local_dir') }
        let(:local_s3_uri) { Hasta::S3URI.new('my-bucket', 'path/to/my/file.txt') }

        it { expect(subject.filters).to be_nil }
        it { expect(subject.combined_storage.files_for(local_s3_uri)).to_not be_empty }
      end
    end
  end
end
