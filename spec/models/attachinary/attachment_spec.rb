require 'spec_helper'

if defined? Attachinary::Attachment
  describe Attachinary::Attachment do
    subject { build(:attachment) }

    describe 'validations' do
      it { should be_valid }
      it { should_not have_valid(:parent_type).when(nil) }
      it { should_not have_valid(:parent_id).when(nil) }
      it { should_not have_valid(:scope).when(nil) }
    end
  end
end
