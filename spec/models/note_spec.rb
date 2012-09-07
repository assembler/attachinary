require 'spec_helper'

describe Note do
  subject { build(:note) }
  let(:gifA) { Rack::Test::UploadedFile.new(File.expand_path('../../support/A.gif', __FILE__), 'image/gif') }
  let(:gifB) { Rack::Test::UploadedFile.new(File.expand_path('../../support/B.gif', __FILE__), 'image/gif') }

  before do
    Cloudinary::Uploader.stub destroy: true
  end

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

        subject.photo_id = nil
        subject.photo.should be_nil
      end

      it 'accepts files' do
        file = create(:file)
        ::Attachinary::File.stub(:upload!).with(gifA, 'photo').and_return(file)

        subject.photo_file = gifA
        subject.photo.should == file
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
        subject.photo_options[:file_field_name].should == 'photo_file'
        subject.photo_options[:maximum].should == 1
        subject.photo_options[:single].should == true
      end
    end

    it 'persists' do
      note1 = create(:note)
      note2 = Note.find(note1.id)
      note2.photo.should == note1.photo
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

        subject.image_ids = [image1.id]
        subject.images.should =~ [image1]

        subject.images.clear
        subject.images.should be_blank
      end

      it 'accepts files' do
        fileA = create(:file)
        fileB = create(:file)
        ::Attachinary::File.stub(:upload!).with(gifA, 'images').and_return(fileA)
        ::Attachinary::File.stub(:upload!).with(gifB, 'images').and_return(fileB)

        subject.image_files = [gifA, gifB]
        subject.images.should =~ [fileA, fileB]
      end
    end

    describe '#image_options' do
      it 'returns association options' do
        subject.image_options[:field_name].should == 'image_ids'
        subject.image_options[:file_field_name].should == 'image_files'
        subject.image_options[:single].should == false
      end
    end
  end


end
