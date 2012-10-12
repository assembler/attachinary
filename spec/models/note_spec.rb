require 'spec_helper'

describe Note do
  subject { build(:note) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:photo).when(nil) }
  end

  describe "callbacks" do
    describe "after_destroy" do
      subject { create(:note) }
      it "destroys attached files" do
        Cloudinary::Uploader.should_receive(:destroy).with(subject.photo.public_id)
        subject.destroy
      end
    end
  end

  describe 'photo attachment' do
    describe '#photo' do
      it 'manages photo' do
        photo1 = build(:file)
        subject.photo = photo1
        subject.photo.should == photo1

        photo2 = build(:file)
        subject.photo = photo2
        subject.photo.should == photo2

        subject.photo = nil
        subject.photo.should be_nil
      end

      it 'accepts stringified JSON' do
        file = build(:file)
        subject.photo = file.to_json
        subject.photo.public_id.should == file.public_id
      end
    end

    describe '#photo?' do
      it 'checks whether photo is present' do
        subject.photo?.should be_true
        subject.photo = nil
        subject.photo?.should be_false
      end
    end

    describe '#photo_metadata' do
      it 'returns association metadata' do
        subject.photo_metadata[:maximum].should == 1
        subject.photo_metadata[:single].should == true
      end
    end
  end

  describe 'image attachments' do
    describe '#images' do
      it 'manages images' do
        subject.images?.should be_false

        image1 = build(:file)
        subject.images << image1
        subject.images.should =~ [image1]

        image2 = build(:file)
        subject.images << image2
        subject.images.should =~ [image1, image2]

        subject.images = nil
        subject.images.should be_blank
      end

      it 'accepts stringified JSON' do
        file = build(:file)

        subject.images = file.to_json
        subject.images.first.public_id.should == file.public_id
      end
    end

    describe '#images_metadata' do
      it 'returns association metadata' do
        subject.images_metadata[:single].should == false
      end
    end
  end
end
