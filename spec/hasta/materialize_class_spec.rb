# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/materialize_class'

describe Hasta::MaterializeClass do
  describe '.from_file' do
    subject { described_class.from_file(file) }

    context 'given a file that follows the naming convention' do
      let(:file) { "#{File.dirname(__FILE__)}/../fixtures/hasta/lib/test_identity_mapper.rb" }

      it { expect(subject.class.name).to eq('TestIdentityMapper') }
    end

    context 'given a file that does not follow the naming convention' do
      let(:file) { "#{File.dirname(__FILE__)}/../fixtures/hasta/lib/unconventional_reducer.rb" }

      it { expect { subject }.to raise_error(Hasta::ClassLoadError) }
    end
  end
end
