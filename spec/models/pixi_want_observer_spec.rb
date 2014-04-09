require 'spec_helper'

describe PixiWantObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:buyer) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }
    let(:pixi_want) { buyer.pixi_wants.build FactoryGirl.attributes_for :pixi_want, pixi_id: listing.pixi_id }

    it 'should deliver the receipt' do
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_interest).with(pixi_want)
      pixi_want.save!
    end

    it 'should add pixi points' do
      pixi_want.save!
      buyer.user_pixi_points.find_by_code('cs').code.should == 'cs'
    end
  end
end