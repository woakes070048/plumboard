require 'spec_helper'

describe PixiLike do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    @pixi_like = @user.pixi_likes.build FactoryGirl.attributes_for :pixi_like, pixi_id: @listing.pixi_id
  end

  subject { @pixi_like }

  it { should respond_to(:pixi_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:listing) }

  it { should validate_presence_of(:pixi_id) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:pixi_id) }
  it { should belong_to(:listing).with_foreign_key('pixi_id') }
  it { should belong_to(:user) }
end