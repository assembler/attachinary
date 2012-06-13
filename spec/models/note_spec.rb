require 'spec_helper'

describe Note do
  subject { build(:note) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:photo_id).when(nil) }
  end

  describe 'photo attachment' do
    describe '#photo, #photo_id' do
      it 'manages photo' do
        subject.photo_id.should == subject.photo.id

        photo1 = create(:file)
        subject.photo_id = photo1.id
        subject.photo.should == photo1

        photo2 = create(:file)
        subject.photo = photo2
        subject.photo_id.should == photo2.id
      end
    end

    describe '#photo?' do
      it 'checks whether photo is present' do
        subject.photo?.should be_true
        subject.photo = nil
        subject.photo?.should be_false
      end
    end

    describe '#photo_options' do
      it 'returns association options' do
        subject.photo_options[:field_name].should == 'photo_id'
        subject.photo_options[:maximum].should == 1
        subject.photo_options[:single].should == true
      end
    end
  end

  describe 'image attachments' do
    describe '#images, #image_ids' do
      it 'manages images' do
        subject.images.should be_blank

        image1 = create(:file)
        subject.images << image1
        subject.images[0].should == image1

        image2 = create(:file)
        subject.images << image2
        subject.images.should =~ [image1, image2]

        subject.images.clear
        subject.images.should be_blank

        subject.image_ids = [image1.id, image2.id]
        subject.images.should =~ [image1, image2]
      end
    end

    describe '#image_options' do
      it 'returns association options' do
        subject.image_options[:field_name].should == 'image_ids'
        subject.image_options[:single].should == false
      end
    end
  end


end
