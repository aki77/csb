require 'ostruct'

RSpec.describe Csb::Col do
  describe '#value_by_item' do
    subject { col.value_by_item(item) }

    let(:item) { OpenStruct.new(name: 'tester', email: 'dummy@dummy.test') }

    context 'block' do
      let(:col) { Csb::Col.new('Name') { |item| item.name } }

      it { is_expected.to eq 'tester' }
    end

    context 'symbol' do
      let(:col) { Csb::Col.new('Name', :name) }

      it { is_expected.to eq 'tester' }
    end

    context 'string' do
      let(:col) { Csb::Col.new('Name', 'dummy') }

      it { is_expected.to eq 'dummy' }
    end

    context 'nil' do
      let(:col) { Csb::Col.new('Name') }

      it { is_expected.to eq nil }
    end
  end
end
