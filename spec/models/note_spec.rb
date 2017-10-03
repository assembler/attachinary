RSpec.describe Note do
  subject { build(:note) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:photo).when(nil) }
  end


  describe "callbacks" do
    let(:photo) { build(:file) }

    describe "after_destroy" do
      after(:each) do
        Cloudinary.config.delete_field(:attachinary_keep_remote) if Cloudinary.config.respond_to?(:attachinary_keep_remote)
      end
      
      it "destroys attached files", :vcr, strategy: :truncation do
        note = create(:note, photo: photo)
        expect(Cloudinary::Uploader).to receive(:destroy).with(photo.public_id).and_call_original
        note.destroy
      end

      it "destroy attached files when association is cleared", :vcr, strategy: :truncation do
        expect(Cloudinary.config.attachinary_keep_remote).to be_falsey
        note = create(:note, optional_photo: photo)
        expect(Cloudinary::Uploader).to receive(:destroy).with(photo.public_id).and_call_original
        note.update!(optional_photo: nil)
      end
      
      it "keeps attached files if Cloudinary.config.attachinary_keep_remote == true", :vcr do
        Cloudinary.config.attachinary_keep_remote = true
        note = create(:note, photo: photo)
        expect(Cloudinary::Uploader).not_to receive(:destroy).with(photo.public_id)
        note.destroy
      end
    end

    describe "after_create" do
      it "removes attachinary_tmp tag from files" do
        expect(Cloudinary::Uploader).to receive(:remove_tag).with(Attachinary::TMPTAG, [photo.public_id])
        create(:note, photo: photo)
      end
    end
  end

  describe 'photo attachment' do
    describe '#photo' do
      it 'manages photo' do
        photo1 = build(:file)
        subject.photo = photo1
        expect(subject.photo).to eq(photo1)

        photo2 = build(:file)
        subject.photo = photo2
        expect(subject.photo).to eq(photo2)

        subject.photo = nil
        expect(subject.photo).to be_nil
      end

      it 'accepts stringified JSON' do
        file = build(:file)
        subject.photo = file.to_json
        expect(subject.photo.public_id).to eq(file.public_id)
      end

      it 'handles invalid JSON from bad browsers (IE)' do
        file = build(:file)
        subject.photo = "[null]"
        expect(subject.photo).to be_nil
      end

      it 'accepts IO objects' do
        image = StringIO.new("")
        file = build(:file)
        expected_id = file.public_id
        expect(Cloudinary::Uploader).to receive(:upload).with(image, resource_type: 'auto').and_return(file.attributes)

        subject.photo = image
        expect(subject.photo.public_id).to eq(expected_id)
      end
    end

    describe '#photo_url=(url)' do
      let(:url) { "http://placehold.it/100x100" }
      let(:file) { build(:file) }
      let(:json) { file.attributes.to_json }

      before do
        expect(Cloudinary::Uploader).to receive(:upload).with(url, resource_type: 'auto').and_return(json)
      end

      it 'uploads photo via url' do
        subject.photo_url = url
        expect(subject.photo.public_id).to eq(file.public_id)
      end
    end

    describe '#photo?' do
      it 'checks whether photo is present' do
        expect(subject.photo?).to be_truthy
        subject.photo = nil
        expect(subject.photo?).to be_falsey
      end
    end

    describe '#photo_metadata' do
      it 'returns association metadata' do
        expect(subject.photo_metadata[:maximum]).to eq(1)
        expect(subject.photo_metadata[:single]).to eq(true)
      end
    end
  end

  describe 'image attachments' do
    describe '#images' do
      it 'manages images' do
        expect(subject.images?).to be_falsey

        image1 = build(:file)
        subject.images << image1
        expect(subject.images).to eq([image1])

        image2 = build(:file)
        subject.images << image2
        expect(subject.images).to eq([image1, image2])

        subject.images = nil
        expect(subject.images).to be_blank
      end

      it 'accepts stringified JSON' do
        file = build(:file)

        subject.images = file.to_json
        expect(subject.images.first.public_id).to eq(file.public_id)
      end

      it 'accepts IO objects' do
        images = [1,2].map { StringIO.new("") }
        files = build_list(:file, images.length)
        files_ids = files.map(&:public_id)

        files.each.with_index do |file, index|
          expect(Cloudinary::Uploader).to receive(:upload).with(images[index], resource_type: 'auto').and_return(file.attributes)
        end

        subject.images = images
        expect(subject.images.map(&:public_id)).to match(files_ids)
      end
    end

    describe '#image_urls=(urls)' do
      let(:urls) { %w[ 1 2 3 ] }
      let(:files) { build_list(:file, urls.length) }
      let(:files_ids) { files.map(&:public_id)}

      before do
        files_ids
        files.each.with_index do |file, index|
          expect(Cloudinary::Uploader).to receive(:upload).with(urls[index], resource_type: 'auto').and_return(file.attributes)
        end
      end

      it 'upload photos via urls' do
        subject.image_urls = urls
        expect(subject.images.map(&:public_id)).to match(files_ids)
      end
    end

    describe '#images_metadata' do
      it 'returns association metadata' do
        expect(subject.images_metadata[:single]).to eq(false)
      end
    end
  end
end
