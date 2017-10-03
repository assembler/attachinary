RSpec.describe Attachinary::File do
  subject { build(:file) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:public_id).when(nil) }
    it { should_not have_valid(:version).when(nil) }
    it { should_not have_valid(:resource_type).when(nil) }
  end

  describe '#path(custom_format=nil)' do
    context "image resource_type" do
      subject { build(:file, public_id: 'id', version: '1', format: 'jpg', resource_type: 'image') }

      it 'allows you to pick format' do
        expect(subject.path).to eq('v1/id.jpg')
        expect(subject.path('png')).to eq('v1/id.png')
        expect(subject.path(false)).to eq('v1/id')
      end
    end

    context "raw resource_type" do
      subject { build(:file, public_id: 'id.txt', version: '1', format: '', resource_type: 'raw') }

      it 'ignores the format' do
        expect(subject.path).to eq('v1/id.txt')
        expect(subject.path('png')).to eq('v1/id.txt')
        expect(subject.path(false)).to eq('v1/id.txt')
      end
    end
  end

  describe '#fullpath(options={})' do
    it 'delegates to Cloudinary' do
      allow(Cloudinary::Utils).to receive(:cloudinary_url).with('v1/id1.png', {resource_type: "image"}).and_return('http_png')
      subject.public_id = 'id1'
      subject.version = '1'
      expect(subject.fullpath(format: 'png')).to eq('http_png')
    end
  end

end
