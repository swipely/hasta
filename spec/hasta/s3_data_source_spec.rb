# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/s3_data_source'

describe Hasta::S3DataSource do
  describe '#each_line' do
    subject { described_class.new(s3_uri, combined_storage) }

    let(:s3_uri) { Hasta::S3URI.parse('s3://my-bucket/path/to/files/') }
    let(:combined_storage) { double(Hasta::CombinedStorage) }

    context 'given an existent path' do
      before do
        combined_storage.stub(:files_for).with(s3_uri).and_return(files)
      end

      let(:files) {
        lines.map { |file_lines|
          Hasta::S3File.new(
            double('Fog::File', :body => file_lines.join("\n"), :key => 'file_name.txt')
          )
        }
      }
      let(:lines) { [ %w[First Second Third], %w[Fourth Fifth] ] }

      it { expect(subject.each_line.to_a.map(&:strip)).to eq(lines.flatten) }
    end

    context 'given a non-existent path' do
      before do
        combined_storage.stub(:files_for).with(s3_uri).and_raise(Hasta::NonExistentPath)
      end

      it { expect { subject.each_line.to_a }.to raise_error(Hasta::NonExistentPath) }
    end
  end
end
