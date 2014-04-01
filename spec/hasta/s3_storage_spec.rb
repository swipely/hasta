# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/s3_storage'

describe Hasta::S3Storage do
  describe '#files_for' do
    subject { described_class.new(fog_storage) }

    before do
      Fog.mock!
      Fog::Mock.reset
    end

    after do
      Fog.unmock!
    end

    let(:fog_storage) { Fog::Storage::AWS.new }

    it_should_behave_like 'a storage service'
  end
end
