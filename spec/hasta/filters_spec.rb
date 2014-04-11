# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/filters'

describe Hasta::Filters do
  describe '.from_file' do
    let(:non_existent_file) { 'spec/fixtures/hasta/non_existent_file.dll' }

    context 'given an non-existent file' do
      it 'raises a ConfigurationError' do
        expect {
          described_class.from_file(non_existent_file)
        }.to raise_error(Hasta::ConfigurationError)
      end
    end
  end

  describe '#for_s3_uri' do
    subject { described_class.new(filters) }

    let(:filters) {
      {
        's3://my-bucket/path1/' => ['.*'],
        's3://my-bucket/path/to/file.txt' => ['[a-z]{2}', '\A_.*'],
        's3://my-bucket/path1/path2/' => ['z.+', 'a.+', 'x.?'],
      }
    }

    context 'given no match' do
      let(:s3_uri) { Hasta::S3URI.new('other-bucket', 'path/to/file.txt') }

      it 'returns nil' do
        expect(subject.for_s3_uri(s3_uri)).to be_nil
      end
    end

    context 'given a single match' do
      let(:s3_uri) { Hasta::S3URI.new('my-bucket', 'path/to/file.txt') }

      it 'selects the only match' do
        expect(subject.for_s3_uri(s3_uri).to_s).to eq('#<Hasta::Filter:[/[a-z]{2}/, /\\A_.*/]>')
      end
    end

    context 'given multiple matches' do
      let(:s3_uri) { Hasta::S3URI.new('my-bucket', 'path1/path2/file3.txt') }

      it 'selects the most specific match' do
        expect(subject.for_s3_uri(s3_uri).to_s).to eq('#<Hasta::Filter:[/a.+/, /x.?/, /z.+/]>')
      end
    end
  end
end
