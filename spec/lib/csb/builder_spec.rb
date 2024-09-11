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

    context 'with utf8 bom' do
      let(:builder) { Csb::Builder.new(items: items, utf8_bom: true) }

      it { is_expected.to eq "\xEF\xBB\xBFName,Email,Dummy\ntester1,dummy1@dummy.test,\ntester2,dummy2@dummy.test,\n" }
    end

    context 'with csv_options' do
      let(:builder) { Csb::Builder.new(items: items, csv_options: { col_sep: "\t" }) }

      it { is_expected.to eq "Name\tEmail\tDummy\ntester1\tdummy1@dummy.test\t\ntester2\tdummy2@dummy.test\t\n" }
    end

    context 'without headers' do
      let(:builder) { Csb::Builder.new(items: items, csv_options: { write_headers: false }) }

      it { is_expected.to eq "tester1,dummy1@dummy.test,\ntester2,dummy2@dummy.test,\n" }
    end
  end
end
