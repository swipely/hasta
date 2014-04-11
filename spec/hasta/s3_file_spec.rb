# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/s3_file'

describe Hasta::S3File do
  describe '.wrap_files' do
    let(:files) { 4.times.map { |i| double("File ##{i}", :key => "File ##{i}") } }

    it { expect(described_class.wrap_files(files).map(&:key)).to eq(files.map(&:key)) }
  end

  describe '.wrap' do
    subject { described_class.wrap(file) }

    let(:fog_file) { double('Fog::File', key: 'path/to/file.txt', body: "WOW\n") }

    context 'given a Fog file' do
      let(:file) { fog_file }

      it { expect(subject).to be_kind_of(described_class) }
      it { expect(subject.key).to eq(fog_file.key) }
    end

    context 'given an S3File' do
      let(:file) { described_class.new(fog_file) }

      it { expect(subject).to be(file) }
    end

    context 'given nil' do
      let(:file) { nil }

      it { expect(subject).to be_nil }
    end
  end

  describe 'instance methods' do
    subject { described_class.new(file) }

    before do
      Fog.mock!
      Fog::Mock.reset
      bucket = fog_storage.directories.create(:key => bucket_name)
      bucket.files.create(:body => contents, :key => path)
    end

    after do
     Fog.unmock!
    end

    let(:fog_storage) { Fog::Storage::AWS.new }
    let(:bucket_name) { 'my-bucket' }
    let(:bucket) { fog_storage.directories.get(bucket_name) }
    let(:path) { 'path/to/my/file.txt' }
    let(:contents) { "\n" }
    let(:etag) { file.etag }

    let(:file) { bucket.files.get(path) }

    describe '#each_line' do
      let(:lines) { ["First\n", "Second\n", "Third\n"] }
      let(:contents) { lines.join }

      it { expect(subject.each_line.to_a).to eq(lines) }
    end

    describe '#key' do
      it { expect(subject.key).to eq(path) }
    end

    describe '#body' do
      let(:contents) { [
        "First\n",
        "Second\n",
        "Third\n",
      ].join }

      it { expect(subject.body).to eq(contents) }
    end

    describe '#s3_uri' do
      it { expect(subject.s3_uri).to eq(Hasta::S3URI.new(bucket.key, path)) }
    end

    describe '#fingerprint' do
      it { expect(subject.fingerprint).to eq(etag) }
    end

    describe '#remote?' do
      it { expect(subject).to be_remote }
    end
  end

  context 'given a local file' do
    subject { described_class.new(file) }

    include_context 'local fog storage'

    before do
      bucket = fog_storage.directories.create(:key => bucket_name)
      bucket.files.create(:body => contents, :key => path)
    end

    let(:file) { fog_storage.directories.get(bucket_name).files.get(path) }

    let(:bucket_name) { 'my-bucket' }
    let(:path) { 'path/to/my/file.txt' }
    let(:contents) { "Hello, World\n" }

    describe '#fingerprint' do
      let(:md5sum) { Digest::MD5.hexdigest(contents) }

      it { expect(subject.fingerprint).to eq(md5sum) }
    end

    describe '#remote?' do
      it { expect(subject).to_not be_remote }
    end
  end
end
