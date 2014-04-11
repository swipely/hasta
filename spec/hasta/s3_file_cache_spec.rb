# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/s3_file_cache'

describe Hasta::S3FileCache do
  subject { described_class.new(fog_storage, bucket_name) }

  let(:bucket_name) { 'cache' }
  let(:bucket) { fog_storage.directories.get(bucket_name) }

  include_context 'local fog storage'

  describe '#get' do
    let(:key) { '12345' }
    let(:body) { "Data\n" }

    context 'given the file exists' do
      before do
        subject
        bucket.files.create(:body => body, :key => key)
      end

      let(:result) { subject.get(key) }

      it { expect(result.body).to eq(body) }
    end

    context 'given the file does not exist' do
      it { expect(subject.get(key)).to be_nil }
    end
  end

  describe '#put' do
    let(:key) { '67899' }
    let(:body) { "Data\nBase\n" }

    it 'stores the file in the cache' do
      subject.put(key, body)

      expect(bucket.files.get(key).body).to eq(body)
    end
  end
end
