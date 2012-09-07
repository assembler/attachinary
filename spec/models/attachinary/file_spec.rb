require 'spec_helper'

describe Attachinary::File do
  subject { build(:file) }
  let(:gif) { Rack::Test::UploadedFile.new(File.expand_path('../../../support/A.gif', __FILE__), 'image/gif') }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:public_id).when(nil) }
    it { should_not have_valid(:version).when(nil) }
    it { should_not have_valid(:resource_type).when(nil) }
    it { should_not have_valid(:scope).when(nil) }
  end

  describe '#path(custom_format=nil)' do
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

  describe '#fullpath(options={})' do
    it 'delegates to Cloudinary' do
      Cloudinary::Utils.stub(:cloudinary_url).with('v1/id1.png', {}).and_return('http_png')
      subject.public_id = 'id1'
      subject.version = '1'
      subject.fullpath(format: 'png').should == 'http_png'
    end
  end

  describe '.upload!(f)' do
    let(:cloudinary_response) {
      {
        public_id: "id",
        version: "1",
        width: 50,
        height: 50,
        format: 'gif',
        resource_type: 'image'
      }
    }

    before do
      stub_request(:post, %r{api.cloudinary.com}).
         to_return(:status => 200, :body => cloudinary_response.to_json)
    end

    it 'uploads file to Cloudinary and returns File object' do
      file = Attachinary::File.upload!(gif, 'photo')
      file.public_id.should == "id"
      file.version.should == "1"
      file.width.should == 50
      file.height.should == 50
      file.format.should == 'gif'
      file.resource_type.should == 'image'
      file.scope.should == 'photo'
    end
  end

end
