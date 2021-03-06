require 'login_user_spec'

describe PicturesController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |listing|
       allow(listing).to receive_messages(stubs) unless stubs.empty?
    end
  end

  describe 'GET /system' do
    before :each do
      @picture = stub_model Picture
      fname = Rails.root.join("spec", "fixtures", "photo.jpg")
      allow(Picture).to receive(:find).and_return( @picture )
      allow(controller).to receive_message_chain(:send_file, :style).with(fname).and_return(:success)
      allow(controller).to receive(:style).and_return('original')
      allow(controller).to receive(:file_name).with(@picture).and_return(fname)
    end

    def do_get
      get :asset, use_route: "/system/pictures/photos/1/original/Guitar_1.jpg", :params => {id: '1', 
      		 "style" => 'original', "filename" => 'Guitar_1.jpg' }
    end

    it "should load picture asset" do
      do_get
      expect(response).to be_success
    end

    it "should load the requested picture" do
      allow(Picture).to receive(:find).with('1').and_return(@picture)
    end

    it "should assign @picture" do
      do_get
      expect(assigns(:picture)).not_to be_nil
    end

    it "should receive send file" do
      expect(controller).to receive(:send_file).and_return(:success) 
      do_get
    end

    it "asset action should render nothing" do
      do_get
      allow(controller).to receive(:render)
    end
  end

  describe "DELETE /:id" do
    before (:each) do
      log_in_test_user
      @listing = stub_model(TempListing, :id=>1, site_id: 1, seller_id: 1, pixi_id: '1', title: "Guitar for Sale", description: "Guitar for Sale")
      allow(TempListing).to receive(:find_by_pixi_id).and_return( @listing )
      allow(@listing).to receive(:reload).and_return(@listing)
    end

    def do_delete
      xhr :delete, :destroy, :id => "1", pixi_id: '1'
    end

    context "success" do
      before :each do
        allow(@listing).to receive(:delete_photo).with('1', 0).and_return(true)
	allow(@listing).to receive(:reload).and_return(@listing)
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { @listing }
        do_delete
      end

      it "should update the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id).with("1") { mock_listing }
	expect(mock_listing).to receive(:delete_photo).and_return(:success)
        do_delete
      end

      it "should assign @listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { mock_listing(:delete_photo => true) }
        do_delete
        expect(assigns(:listing)).not_to be_nil 
      end

      it "should decrement the Picture count" do
	lambda do
	  do_delete
	  is_expected.to change(Picture, :count).by(-1)
	end
      end
    end

    context 'failure' do
      before :each do
        allow(@listing).to receive(:delete_photo).with('1', 0).and_return(false) 
      end

      it "should assign listing" do
        do_delete
        expect(assigns(:listing)).not_to be_nil 
      end

      it "should render nothing" do
        do_delete
        allow(controller).to receive(:render)
      end
    end
  end

  describe 'GET show/:id' do
    before :each do
      @picture = mock_model Picture
      allow(Picture).to receive(:find).and_return( @picture )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested picture" do
      do_get
      expect(response).to be_success
    end

    it "should load the requested picture" do
      allow(Picture).to receive(:find).with('1').and_return(@picture)
      do_get
    end

    it "should assign @picture" do
      do_get
      expect(assigns(:picture)).not_to be_nil
    end
  end
end
