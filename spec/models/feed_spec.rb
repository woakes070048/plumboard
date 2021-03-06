require 'spec_helper'

describe Feed do
  before :each do
    @feed = create :feed
  end

  subject { @feed }
  describe 'attributes', base: true do
    describe '#attributes' do
      subject { super().attributes }
      it { is_expected.to include(*%w(description site_id site_name status url)) }
    end
    it { is_expected.to validate_presence_of(:url) }
  end
end