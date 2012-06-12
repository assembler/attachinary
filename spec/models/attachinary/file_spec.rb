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
    subject { build(:file, public_id: 'id', version: '1', format: 'jpg') }
    it 'returns proper cloudinary file name' do
      subject.path.should == 'v1/id.jpg'
      subject.path('png').should == 'v1/id.png'
    end
  end

end
