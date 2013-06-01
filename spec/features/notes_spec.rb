require 'spec_helper'

describe 'Notes' do


  describe 'Creating new note' do

    shared_examples_for "any form" do
      before do
        visit path
      end

      it 'checks file type' do
        within 'div.photo' do
          handle_alert do |message|
            attach_file 'note[photo]', File.expand_path("../../support/A.txt", __FILE__)
            Timeout::timeout(5) do
              begin
                sleep 0.250
              end while alert_message.blank?
              alert_message.downcase.should == 'invalid file format'
            end
          end
        end
      end

      it 'disables input when first photo is uploaded' do
        within 'div.photo' do
          attach_file "note[photo]", File.expand_path('../../support/A.gif', __FILE__)
          page.should have_css 'input[disabled]'
        end
      end

      it 'allows multiple images to be uploaded' do
        within 'div.images' do
          attach_file "note[images][]", File.expand_path('../../support/A.gif', __FILE__)
          page.should have_css 'input:not([disabled])'
          attach_file "note[images][]", File.expand_path('../../support/B.gif', __FILE__)
          page.should have_css 'input:not([disabled])'
        end
      end

      it 'preserves uploaded photo accross postbacks' do
        within 'div.photo' do
          attach_file "note[photo]", File.expand_path('../../support/A.gif', __FILE__)
          page.should have_css 'img'
        end

        page.should have_button 'Create Note' # wait for it to appear
        click_button 'Create Note'

        within 'div.photo' do
          page.should have_css 'img'
        end
      end

      it 'validates presence of photo' do
        click_button 'Create Note'
        within 'div.photo' do
          page.should have_content "can't be blank"
        end
      end

      it 'saves the record' do
        fill_in 'note[body]', with: 'My Note'
        within 'div.photo' do
          attach_file "note[photo]", File.expand_path('../../support/A.gif', __FILE__)
        end
        click_button 'Create Note'

        current_path.should == notes_path
        page.should have_content 'My Note'
        page.should have_css 'img'
      end

    end


    context 'raw form', :js do
      let(:path) { new_note_path(kind: 'raw') }
      it_behaves_like "any form"
    end

    context 'builder form', :js do
      let(:path) { new_note_path(kind: 'builder') }
      it_behaves_like "any form"
    end


    context 'simple_form', :js do
      let(:path) { new_note_path(kind: 'simple_form') }
      it_behaves_like "any form"
    end

  end

end
