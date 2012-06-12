require 'spec_helper'

describe Attachinary::File do
  subject { build(:attachment) }

  describe 'validations' do
    it { should be_valid }
    it { should_not have_valid(:parent_type).when(nil) }
    it { should_not have_valid(:parent_id).when(nil) }
    it { should_not have_valid(:scope).when(nil) }
  end

end
