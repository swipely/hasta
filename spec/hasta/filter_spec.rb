# Copyright Swipely, Inc.  All rights reserved.

require 'spec_helper'

require 'hasta/filter'

describe Hasta::Filter do
  context 'given a single regex' do
    subject { described_class.new(regex) }

    let(:regex) { /\A\d{1,}.*/ }
    let(:drop_all) { ['First', 'Second', 'Third'] }
    let(:drop_none) { ['1. First', '2. Second'] }
    let(:drop_some) { ['1 First', 'Second', '3 Third'] }

    it { expect(drop_all.select(&subject)).to be_empty }
    it { expect(drop_none.select(&subject)).to eq(drop_none) }
    it { expect(drop_some.select(&subject)).to eq(['1 First', '3 Third']) }
  end

  context 'given multiple regexes' do
    subject { described_class.new(regex1, regex2) }

    let(:regex1) { /\A\d{1,}.*/ }
    let(:regex2) { /\A[A-Z].*/ }

    let(:drop_all) { ['first', 'second', 'third'] }
    let(:drop_none) { ['1. First', '2. Second', 'Third'] }
    let(:drop_some) { ['First', 'second', '3 Third'] }

    it { expect(drop_all.select(&subject)).to be_empty }
    it { expect(drop_none.select(&subject)).to eq(drop_none) }
    it { expect(drop_some.select(&subject)).to eq(['First', '3 Third']) }
  end

  context 'given multiple identical regexes' do
    subject { described_class.new(regex1, regex1) }

    let(:regex1) { /\A\d{1,}.*/ }
    let(:single_regex_filter) { described_class.new(regex1) }

    it { expect(subject.to_s).to eq(single_regex_filter.to_s) }
  end

  context 'given distinct regexes in a different order' do
    subject { described_class.new(regex1, regex2) }

    let(:regex1) { /\A\d{1,}.*/ }
    let(:regex2) { /\A[A-Z].*/ }
    let(:different_order_filter) { described_class.new(regex2, regex1) }

    it { expect(subject.to_s).to eq(different_order_filter.to_s) }
  end

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
end
