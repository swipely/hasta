# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/resolve_cached_s3_file'

describe Hasta::ResolveCachedS3File do
  describe '#resolve' do
    subject { described_class.new(file_cache, child_resolver) }

    let(:file_cache) { double(Hasta::S3FileCache) }
    let(:child_resolver) { Hasta::ResolveFilteredS3File.new(filters) }
    let(:filters) { Hasta::Filters.new({ "s3://#{bucket_name}" => ['.*'] }) }

    let(:fog_file) {
      double('Fog::File',
        :directory => fog_bucket,
        :key => path,
        :body => body
      )
    }
    let(:fog_bucket) { double('Fog::Directory', :key => bucket_name) }
    let(:bucket_name) { 'my-bucket' }
    let(:path) { 'path/to/my/file.txt' }
    let(:body) { "Parts\n" }
    let(:s3_uri) { Hasta::S3URI.new(bucket_name, path) }
    let(:exp_filter) { filters.for_s3_uri(s3_uri) }

    let(:exp_fingerprint) {
      Digest::MD5.hexdigest("#{Digest::MD5.hexdigest(body)}_#{exp_filter.to_s}")
    }

    let(:result) { subject.resolve(fog_file) }

    context 'given the file is not cached' do
      before do
        file_cache.stub(:get).and_return(nil)
      end

      it 'caches the file' do
        file_cache.should_receive(:put).with(exp_fingerprint, body)

        expect(result.body).to eq(body)
        expect(result.s3_uri).to eq(s3_uri)
      end
    end

    context 'given the file is cached' do
      before do
        file_cache.stub(:get).with(exp_fingerprint).and_return(cached_file)
      end

      let(:cached_file) {
        double('Fog::File',
          :directory => double('Fog::Bucket', :key => 'cache_dir'),
          :key => exp_fingerprint,
          :body => body
        )
      }

      it 'retrieves the cached file' do
        file_cache.should_not_receive(:put)

        expect(result.body).to eq(body)
        expect(result.s3_uri).to eq(s3_uri)
      end
    end
  end
end