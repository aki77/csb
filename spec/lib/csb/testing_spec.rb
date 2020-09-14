require 'ostruct'
require 'csb/testing'

RSpec.describe Csb::Cols do
  let(:cols) { Csb::Cols.new }

  before do
    cols.add('Name') { |item| item.name }
    cols.add('Email', :email)
    cols.add('Dummy')
  end

  describe '#col_pairs' do
    subject { cols.col_pairs(item) }

    let(:item) { OpenStruct.new(name: 'tester', email: 'dummy@dummy.test') }

    it { is_expected.to eq [%w[Name tester], %w[Email dummy@dummy.test], ['Dummy', nil]] }
  end

  describe '#as_table' do
    subject { cols.as_table(items) }

    let(:items) do
      [
        OpenStruct.new(name: 'tester1', email: 'dummy1@dummy.test'),
        OpenStruct.new(name: 'tester2', email: 'dummy2@dummy.test')
      ]
    end

    it { is_expected.to eq [%w[Name Email Dummy], ['tester1', 'dummy1@dummy.test', nil], ['tester2', 'dummy2@dummy.test', nil]] }
  end
end
