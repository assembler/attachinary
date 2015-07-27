require 'rails_helper'

describe 'Notes' do
  Capybara.default_wait_time = 10
  SHORT_SLEEP = 3

  describe 'Creating new note' do

    shared_examples_for "any form" do
      before do
        visit path
      end

      it 'checks file type', :js => true do
        within 'div.photo' do
          handle_alert do |message|
            attach_file 'note[photo]', "#{SPEC_ROOT}/support/A.txt"
            Timeout::timeout(5) do
              begin
                sleep 0.250
              end while alert_message.blank?
              alert_message.downcase.should == 'invalid file format'
            end
          end
        end
      end

      it 'disables input when first photo is uploaded', :js => true do
        within 'div.photo' do
          attach_file "note[photo]", "#{SPEC_ROOT}/support/A.gif"
          page.should have_css 'input[disabled]'
        end
      end

      it 'allows multiple images to be uploaded', :js => true do
        within 'div.images' do
          attach_file "note[images][]", "#{SPEC_ROOT}/support/A.gif"
          sleep SHORT_SLEEP
          value = find(:xpath, './/input[@name="note[images][]" and @type="hidden" ]', :visible => false).value
          images = ActiveSupport::JSON.decode( value)
          images.length.should be 1
          images.map{|i| i["original_filename"]}.should eq ["A"]

          attach_file "note[images][]", "#{SPEC_ROOT}/support/B.gif"
          sleep SHORT_SLEEP
          value = find(:xpath, './/input[@name="note[images][]" and @type="hidden" ]', :visible => false).value
          images = ActiveSupport::JSON.decode( value)
          images.length.should be 2
          images.map{|i| i["original_filename"]}.sort.should eq ["A", "B"]
        end
      end

      it 'preserves uploaded photo across postbacks', :js => true do
        within 'div.photo' do
          attach_file "note[photo]", "#{SPEC_ROOT}/support/A.gif"
          page.should have_css 'img'
        end

        page.should have_button 'Create Note' # wait for it to appear
        click_button 'Create Note'

        within 'div.photo' do
          page.should have_css 'img'
        end
      end

      it 'validates presence of photo', :js => true do
        click_button 'Create Note'
        within 'div.photo' do
          page.should have_content "can't be blank"
        end
      end

      it 'saves the record', :js => true do
        fill_in 'note[body]', with: 'My Note'
        within 'div.photo' do
          attach_file "note[photo]", "#{SPEC_ROOT}/support/A.gif"
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
