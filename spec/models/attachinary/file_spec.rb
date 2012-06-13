require 'spec_helper'

describe Attachinary::File do
  subject { build(:file) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:public_id).when(nil) }
    it { should_not have_valid(:version).when(nil) }
    it { should_not have_valid(:resource_type).when(nil) }
  end

  describe '#path' do
    context "image resource_type" do
      subject { build(:file, public_id: 'id', version: '1', format: 'jpg', resource_type: 'image') }

      it 'allows you to pick format' do
        subject.path.should == 'v1/id.jpg'
        subject.path('png').should == 'v1/id.png'
        subject.path(false).should == 'v1/id'
      end
    end

    context "raw resource_type" do
      subject { build(:file, public_id: 'id.txt', version: '1', format: '', resource_type: 'raw') }

      it 'ignores the format' do
        subject.path.should == 'v1/id.txt'
        subject.path('png').should == 'v1/id.txt'
        subject.path(false).should == 'v1/id.txt'
      end
    end
  end

end
