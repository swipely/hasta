# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

describe Hasta::Configuration do
  describe '#sort_by' do
    before do
      Hasta.sort_by { |key| key.upcase }
    end

    let(:values) { ['Zebra', 'Antelope', 'giraffe', 'aardvark'] }
    let(:sorted_values) { ['aardvark', 'Antelope', 'giraffe', 'Zebra'] }

    it { expect(values.sort_by(&Hasta.sort_by)).to eq(sorted_values) }
    it { expect(Hasta.sort_by).to be_lambda }
  end
end
