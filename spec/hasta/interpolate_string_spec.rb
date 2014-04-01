# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/interpolate_string'

describe Hasta::InterpolateString do
  describe '#evaluate' do
    subject { described_class.new(text) }

    let(:context) { { 'scheduledStartTime' => Time.parse('2014-03-28T18:05:11Z') } }

    context 'given static text' do
      let(:text) { 'Static text' }

      it { expect(subject.evaluate(context)).to eq(text) }
    end

    context 'given text with a known interpolate time expression' do
      let(:text) {
        's3://my-bucket/path/to/dir/#{format(@scheduledStartTime,\'YYYY-MM-dd_HHmmss\')}/files/'
      }
      let(:interpolated_text) { 's3://my-bucket/path/to/dir/2014-03-28_180511/files/' }

      it { expect(subject.evaluate(context)).to eq(interpolated_text) }
    end

    context 'given text with a known interpolate date expression' do
      let(:text) {
        's3://my-bucket/path/to/dir/#{format(@scheduledStartTime,\'YYYY-MM-dd\')}/files/'
      }
      let(:interpolated_text) { 's3://my-bucket/path/to/dir/2014-03-28/files/' }

      it { expect(subject.evaluate(context)).to eq(interpolated_text) }
    end

    context 'given text with an unknown interpolate expression' do
      let(:time) { '#{format(minusMinutes(@scheduledStartTime,30),\'YYYY-MM-dd hh:mm:ss\')}' }
      let(:text) { "s3://my-bucket/path/to/dir/#{time}/files/" }

      it { expect(subject.evaluate(context)).to eq(text) }
    end
  end
end
