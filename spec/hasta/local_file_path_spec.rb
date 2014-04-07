# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/local_file_path'

describe Hasta::LocalFilePath do
  describe '.for' do
    subject { described_class.for(s3_uri) }

    let(:s3_uri) { Hasta::S3URI.new(bucket_name, path) }
    let(:bucket_name) { 'my-bucket' }
    let(:path) { 'path/to/my/file.txt' }
    let(:exp_path) { File.expand_path("#{Hasta.local_storage_root}/#{bucket_name}/#{path}") }

    it { expect(subject).to eq(exp_path) }
  end
end
