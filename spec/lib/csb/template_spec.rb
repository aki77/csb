require 'ostruct'
require 'csb/template'

RSpec.describe Csb::Template do
  describe '#build' do
    before do
      template.items = [
        OpenStruct.new(name: 'tester1', email: 'dummy1@dummy.test'),
        OpenStruct.new(name: 'tester2', email: 'dummy2@dummy.test')
      ]
      template.cols.add('Name') { |item| item.name }
      template.cols.add('Email', :email)
      template.cols.add('Dummy')
    end

    context 'Streaming' do
      subject(:enum) { template.build }

      let(:template) { Csb::Template.new(streaming: true, utf8_bom: false) }

      it 'Is a Enumerator' do
        expect(enum).to be_a Enumerator
        expect(enum.next).to eq "Name,Email,Dummy\n"
        expect(enum.next).to eq "tester1,dummy1@dummy.test,\n"
        expect(enum.next).to eq "tester2,dummy2@dummy.test,\n"
      end
    end

    context 'Not streaming' do
      subject { template.build }

      let(:template) { Csb::Template.new(streaming: false, utf8_bom: false) }

      it { is_expected.to eq "Name,Email,Dummy\ntester1,dummy1@dummy.test,\ntester2,dummy2@dummy.test,\n" }
    end
  end
end
