# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/combined_storage'

describe Hasta::CombinedStorage do
  describe '#files_for' do
    subject { described_class.new(s3_storage, local_storage) }

    let(:s3_storage) { double(Hasta::Storage) }
    let(:local_storage) { double(Hasta::Storage) }

    let(:s3_uri) { Hasta::S3URI.parse('s3://my-bucket/path/to/files/') }

    context 'given files exist locally' do
      before do
        local_storage.stub(:exists?).with(s3_uri).and_return(true)
      end

      let(:files) { 3.times.map { double('Local File') } }

      it 'reads from the local filesystem' do
        local_storage.should_receive(:files_for).with(s3_uri).and_return(files)

        expect(subject.files_for(s3_uri)).to eq(files)
      end
    end

    context 'given files do not exist locally' do
      before do
        local_storage.stub(:exists?).with(s3_uri).and_return(false)
      end

      context 'given files exist remotely' do
        let(:files) { 3.times.map { double('S3 File') } }

        it 'read from S3' do
          s3_storage.should_receive(:files_for).with(s3_uri).and_return(files)

          expect(subject.files_for(s3_uri)).to eq(files)
        end
      end

      context 'given no files exist remotely' do
        it 'raises' do
          s3_storage.should_receive(:files_for).with(s3_uri).and_raise(Hasta::NonExistentPath)

          expect { subject.files_for(s3_uri) }.to raise_error(Hasta::NonExistentPath)
        end
      end
    end
  end
end
