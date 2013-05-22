require 'spec_helper'

describe Note do
  subject { build(:note) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:photo).when(nil) }
  end


  describe "callbacks" do
    let(:photo) { build(:file) }

    describe "after_destroy" do
      it "destroys attached files" do
        note = create(:note, photo: photo)
        Cloudinary::Uploader.should_receive(:destroy).with(photo.public_id)
        note.destroy
      end
    end

    describe "after_create" do
      it "removes attachinary_tmp tag from files" do
        Cloudinary::Uploader.should_receive(:remove_tag).with(Attachinary::TMPTAG, [photo.public_id])
        create(:note, photo: photo)
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

      it 'handles invalid JSON from bad browsers (IE)' do
        file = build(:file)
        subject.photo = "[null]"
        subject.photo.should be_nil
      end

      it 'accepts IO objects' do
        image = StringIO.new("")
        file = build(:file)

        Cloudinary::Uploader.should_receive(:upload).with(image, resource_type: 'auto').and_return(file.attributes)

        subject.photo = image
        subject.photo.public_id.should == file.public_id
      end
    end

    describe '#photo_url=(url)' do
      let(:url) { "http://placehold.it/100x100" }
      let(:file) { build(:file) }
      let(:json) { file.attributes.to_json }

      before do
        Cloudinary::Uploader.should_receive(:upload).with(url, resource_type: 'auto').and_return(json)
      end

      it 'uploads photo via url' do
        subject.photo_url = url
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

      it 'accepts IO objects' do
        images = [1,2].map { StringIO.new("") }
        files = build_list(:file, images.length)

        files.each.with_index do |file, index|
          Cloudinary::Uploader.should_receive(:upload).with(images[index], resource_type: 'auto').and_return(file.attributes)
        end

        subject.images = images
        subject.images.map(&:public_id).should =~ files.map(&:public_id)
      end
    end

    describe '#image_urls=(urls)' do
      let(:urls) { %w[ 1 2 3 ] }
      let(:files) { build_list(:file, urls.length) }

      before do
        files.each.with_index do |file, index|
          Cloudinary::Uploader.should_receive(:upload).with(urls[index], resource_type: 'auto').and_return(file.attributes)
        end
      end

      it 'upload photos via urls' do
        subject.image_urls = urls
        subject.images.map(&:public_id).should =~ files.map(&:public_id)
      end
    end

    describe '#images_metadata' do
      it 'returns association metadata' do
        subject.images_metadata[:single].should == false
      end
    end
  end
end
