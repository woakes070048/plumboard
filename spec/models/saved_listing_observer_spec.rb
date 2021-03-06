require 'spec_helper'

describe SavedListingObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }
    let(:saved_listing) { user.saved_listings.build FactoryGirl.attributes_for :saved_listing, pixi_id: listing.pixi_id }

    it 'should deliver the email' do
      @user_mailer = double(UserMailer)
      allow(UserMailer).to receive(:delay).and_return(UserMailer)
      expect(UserMailer).to receive(:send_save_pixi).with(saved_listing)
      saved_listing.save
      
    end

    it 'should add pixi points' do
      saved_listing.save
      #expect(user).not_to be_nil
      #expect(user.user_pixi_points.count).to eq(1)
      #expect (user.user_pixi_points. Where (code: 'spr').count).to eq(1)
      expect(user.reload.user_pixi_points.find_by_code('spr').code).to eq('spr')
    end
  end
end
