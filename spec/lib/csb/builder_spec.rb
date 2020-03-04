require 'ostruct'

RSpec.describe Csb::Builder do
  describe '#build' do
    subject { builder.build }

    let(:items) do
      [
        OpenStruct.new(name: 'tester1', email: 'dummy1@dummy.test'),
        OpenStruct.new(name: 'tester2', email: 'dummy2@dummy.test')
      ]
    end

    before do
      builder.cols.add('Name') { |item| item.name }
      builder.cols.add('Email', :email)
      builder.cols.add('Dummy')
    end

    context 'default' do
      let(:builder) { Csb::Builder.new(items: items) }

      it { is_expected.to eq "Name,Email,Dummy\ntester1,dummy1@dummy.test,\ntester2,dummy2@dummy.test,\n" }
    end

    context 'Nested array items' do
      let(:builder) { Csb::Builder.new(items: items) }

      let(:items) do
        [
          [OpenStruct.new(name: 'tester1', email: 'dummy1@dummy.test'), 5],
          [OpenStruct.new(name: 'tester2', email: 'dummy2@dummy.test'), 10],
        ]
      end

      before do
        builder.cols.add('Count') { |item, count| count }
      end

      it { is_expected.to eq "Name,Email,Dummy,Count\ntester1,dummy1@dummy.test,,5\ntester2,dummy2@dummy.test,,10\n" }
    end

    context 'with utf8 bom' do
      let(:builder) { Csb::Builder.new(items: items, utf8_bom: true) }

      it { is_expected.to eq "\xEF\xBB\xBFName,Email,Dummy\ntester1,dummy1@dummy.test,\ntester2,dummy2@dummy.test,\n" }
    end
  end
end
