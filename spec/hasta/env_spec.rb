# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/env'

describe Hasta::Env do
  describe '#setup' do
    subject { described_class.new(variables, files, combined_storage) }

    let(:combined_storage) { double(Hasta::CombinedStorage) }
    let(:file) { double('File', :body => contents, :key => s3_uri.path) }
    let(:contents) { "one,two,three\nfour,five,six" }

    let(:variables) { { 'API_KEY' => '123456' } }
    let(:files) { { 'DATA_FILE_PATH' => s3_uri } }
    let(:s3_uri) { Hasta::S3URI.parse('s3://my-bucket/path/to/data.csv') }

    it 'writes the file locally and includes the path in the ENV' do
      combined_storage.
        should_receive(:write).
        with(s3_uri, kind_of(Hasta::S3DataSource)).
        and_return(s3_uri)

      expect(subject.setup).to eq(
        variables.merge({ 'DATA_FILE_PATH' => Hasta::LocalFilePath.for(s3_uri) })
      )
    end
  end
end
