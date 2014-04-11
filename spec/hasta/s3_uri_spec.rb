# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/s3_uri'

describe Hasta::S3URI do
  describe '.parse' do
    subject { described_class.parse(uri) }

    context 'given a bucket only' do
      let(:uri) { "s3://#{bucket}" }
      let(:bucket) { 'my-files' }

      it { expect(subject.bucket).to eq(bucket) }
      it { expect(subject.path).to be_nil }
      it { expect(subject.depth).to eq(1) }
    end

    context 'given a bucket and a file path' do
      let(:uri) { "s3://#{bucket}/#{path}" }
      let(:bucket) { 'my-files' }
      let(:path) { 'path/to/file.txt' }

      it { expect(subject.bucket).to eq(bucket) }
      it { expect(subject.path).to eq(path) }
      it { expect(subject.depth).to eq(4) }
    end

    context 'given a bucket and a directory path' do
      let(:uri) { "s3://#{bucket}/#{path}" }
      let(:bucket) { 'my-files' }
      let(:path) { 'path/to/files/' }

      it { expect(subject.bucket).to eq(bucket) }
      it { expect(subject.path).to eq(path) }
      it { expect(subject.depth).to eq(4) }
    end

    context 'given an s3n URI with a bucket and a directory path' do
      let(:uri) { "s3n://#{bucket}/#{path}" }
      let(:bucket) { 'my-files' }
      let(:path) { 'path/to/files/' }

      it { expect(subject.bucket).to eq(bucket) }
      it { expect(subject.path).to eq(path) }
      it { expect(subject.depth).to eq(4) }
    end

    context 'given an invalid uri' do
      let(:uri) { 'https://swipely.com' }

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#file?' do
    subject { described_class.new(bucket, path) }

    let(:bucket) { 'my-files' }

    context 'given a file path' do
      let(:path) { 'path/to/file.txt' }

      it { expect(subject).to be_file }
    end

    context 'given a directory path' do
      let(:path) { 'path/to/files/' }

      it { expect(subject).to_not be_file }
    end

    context 'given a bucket only path' do
      let(:path) { nil }

      it { expect(subject).to_not be_file }
    end
  end

  describe '#basename' do
    subject { described_class.new(bucket, path) }

    context 'given a file' do
      let(:bucket) { 'my-files' }
      let(:path) { 'path/to/file.txt' }

      it { expect(subject.basename).to eq('file.txt') }
    end

    context 'given a directory' do
      let(:bucket) { 'my-files' }
      let(:path) { 'path/to/files/' }

      it { expect(subject.basename).to eq('files') }
    end

    context 'given only a bucket' do
      let(:bucket) { 'my-files' }
      let(:path) { nil }

      it { expect(subject.basename).to eq('') }
    end
  end

  describe '#append' do
    subject { described_class.new(bucket, path) }

    let(:bucket) { 'my-bucket' }

    context 'given a file path' do
      let(:path) { 'path/to/file.txt' }
      let(:append_path) { 'file.csv' }

      it { expect { subject.append(append_path) }.to raise_error(ArgumentError) }
    end

    context 'given a directory path' do
      let(:path) { 'path/to/' }
      let(:result) { subject.append(append_path) }

      context 'given a file path is appended' do
        let(:append_path) { 'file.csv' }

        it { expect(result).to be_file }
        it { expect(result.path).to eq(File.join(path, append_path)) }
      end

      context 'given a directory path is appended' do
        let(:append_path) { 'dir/' }

        it { expect(result).to be_directory }
        it { expect(result.path).to eq(File.join(path, append_path)) }
      end
    end
  end

  describe '#parent' do
    subject { described_class.new(bucket, path) }

    let(:bucket) { 'my-bucket' }

    context 'given a bucket-only uri' do
      let(:path) { nil }

      it { expect(subject.parent).to be_nil }
    end

    context 'given a file uri' do
      let(:path) { 'path/to/my/file.txt' }

      it { expect(subject.parent).to eq(described_class.new(bucket, 'path/to/my/')) }
    end

    context 'given a directory uri' do
      let(:path) { 'path/to/my/files/' }

      it { expect(subject.parent).to eq(described_class.new(bucket, 'path/to/my/')) }
    end
  end

  describe '#start_with?' do
    subject { described_class.new(bucket, path) }

    let(:bucket) { 'my-bucket' }
    let(:path) { 'path/to/my/favorite/file.txt' }

    let(:other_bucket_uri) { described_class.new('some-other-bucket', path) }
    let(:other_path_uri) { described_class.new(bucket, 'path/to/your/favorite/file.txt') }
    let(:similar_prefix_uri) { described_class.new(bucket, 'path/to/my/fav') }
    let(:bucket_only_uri) { described_class.new(bucket, nil) }

    it { expect(subject.start_with?(subject)).to be_true }
    it { expect(subject.start_with?(subject.parent)).to be_true }
    it { expect(subject.start_with?(subject.parent.parent)).to be_true }
    it { expect(subject.start_with?(other_bucket_uri)).to be_false }
    it { expect(subject.start_with?(other_path_uri)).to be_false }
    it { expect(subject.start_with?(similar_prefix_uri)).to be_false }
    it { expect(subject.start_with?(bucket_only_uri)).to be_true }
  end
end
