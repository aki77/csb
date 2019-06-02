require 'ostruct'

RSpec.describe Csb::Cols do
  let(:cols) { Csb::Cols.new }

  before do
    cols.add('Name') { |item| item.name }
    cols.add('Email', :email)
    cols.add('Dummy')
  end

  describe '#headers' do
    subject { cols.headers }

    it { is_expected.to eq %w[Name Email Dummy] }
  end

  describe '#values_by_item' do
    subject { cols.values_by_item(item) }

    let(:item) { OpenStruct.new(name: 'tester', email: 'dummy@dummy.test') }

    it { is_expected.to eq ['tester', 'dummy@dummy.test', nil] }
  end
end
