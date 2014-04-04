# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/filtered_s3_file'

describe Hasta::FilteredS3File do
  describe '#each_line' do
    subject { described_class.new(s3_file, filter) }

    let(:s3_file) { Hasta::S3File.new(fog_file) }
    let(:fog_file) {
      double('Fog::File',
        :key => 'code/1986/HELLO.BAS',
        :body => lines.join,
        :etag => '696b61f4be8b11e383a37831c1ce6688'
      )
    }
    let(:lines) {
      [
        "10 PRINT \"Hello World\"\n",
        "20 GOTO 10\n",
        "30 END\n",
      ]
    }

    context 'given a filter that drops every line' do
      let(:filter) { Hasta::Filter.new(/.^/) }
      let(:exp_fingerprint) { '86dbb833a45ad24fd37614e0c7ffd8e8' }

      it { expect(subject.each_line.to_a).to be_empty }
      it { expect(subject.body).to be_empty }
      it { expect(subject.fingerprint).to eq(exp_fingerprint) }
    end

    context 'given a filter that drops some lines' do
      let(:filter) { Hasta::Filter.new(/\A[1,3]/) }
      let(:exp_fingerprint) { '5d4cb405a76c3c3c910633a7da3709a4' }

      it { expect(subject.each_line.to_a).to eq(lines.values_at(0, 2)) }
      it { expect(subject.body).to eq(lines.values_at(0, 2).join) }
      it { expect(subject.fingerprint).to eq(exp_fingerprint) }
    end
  end
end
