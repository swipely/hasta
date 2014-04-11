# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

describe Hasta::ResolveFilteredS3File do
  describe '#resolve' do
    subject { described_class.new(filters) }

    let(:filters) { Hasta::Filters.new('s3://my-bucket/path/to/my/files/' => ['\A\d{1,3}.*']) }
    let(:fog_file) {
      double('Fog::File',
        :directory => double('Fog::Directory', :key => bucket_name),
        :key => path
      )
    }
    let(:bucket_name) { 'my-bucket' }

    context 'given a filtered file' do
      let(:path) { 'path/to/my/files/1.txt' }

      it { expect(subject.resolve(fog_file)).to be_kind_of(Hasta::FilteredS3File) }
    end

    context 'given a non-filtered file' do
      let(:path) { 'path/to/your/files/1.txt' }

      it { expect(subject.resolve(fog_file)).to be_kind_of(Hasta::S3File) }
    end
  end
end
