require 'spec_helper'

feature "TempListings" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:submit) { "Next" }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
    @user = user
  end

  def click_cancel_ok
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.accept
  end

  def click_cancel_cancel
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.dismiss
  end

  def click_remove_ok
    click_link 'Remove'
    page.driver.browser.switch_to.alert.accept
  end

  def click_remove_cancel
    click_link 'Remove'
    page.driver.browser.switch_to.alert.dismiss
  end

  def select_site
    select("SFSU", :from => "temp_listing_site_id")
  end

  def select_category
    select('Foo Bar', :from => 'temp_listing_category_id')
  end

  def select_date fld
    page.execute_script %Q{ $("##{fld}").trigger("focus") } # activate datetime picker
    page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
    page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15
  end

  describe "Manage Temp Pixis" do
    let(:temp_listing) { FactoryGirl.build(:temp_listing) }

    before(:each) do
      FactoryGirl.create :site
      FactoryGirl.create :category 
      FactoryGirl.create :category, name: 'Event'
      FactoryGirl.create :category, name: 'Jobs'
      visit new_temp_listing_path
    end

    it { should have_selector('.sm-thumb') }
    it { should have_selector('#photo') }
    it { should have_link 'Cancel', href: listings_path }
    it { should have_button 'Next' }

    def add_data
      fill_in 'Title', with: "Guitar for Sale"
      select_site
      select_category
      fill_in 'Description', with: "Guitar for Sale"
    end

    def add_data_w_photo
      attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
      add_data
    end

    def event_data sdt, edt
      attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
      fill_in 'Title', with: "Guitar for Sale"
      select_site
      select('Event', :from => 'temp_listing_category_id')
      fill_in 'Description', with: "Guitar for Sale"
      fill_in 'start-date', with: sdt
      fill_in 'end-date', with: edt
    end

    describe "Create with invalid information" do
      it "should not create a listing" do
        expect { click_button submit }.not_to change(TempListing, :count)
	page.should have_content "Title can't be blank"
      end

      it "should not create a listing w/o site" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          select_category
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "Site can't be blank"
      end

      it "does not create a listing w/o category" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
	  select_site
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "Category can't be blank"
      end

      it "does not create a listing w/o description" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
	  select_site
          select_category
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "Description can't be blank"
      end

      it "does not create a listing w/o start date" do
        expect { 
	  event_data nil, Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "Start Date is not a valid date"
      end

      it "does not create a listing w/ bad start date" do
        expect { 
	  event_data "30/30/2456", Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "Start Date is not a valid date"
      end

      it "does not create a listing w/ invalid start date" do
        expect { 
	  event_data Date.yesterday.strftime('%m/%d/%Y'), Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "Start Date must be on or after "
      end

      it "does not create a listing w/o end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), nil
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "End Date is not a valid date"
      end

      it "does not create a listing w/ bad end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), "30/30/2456"
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "End Date is not a valid date"
      end

      it "does not create a listing w/ invalid end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), Date.yesterday.strftime('%m/%d/%Y') 
	  click_button submit }.not_to change(TempListing, :count)

	  page.should have_content "End Date must be on or after"
      end

      it "should not create a listing w/o photo" do
        expect { 
	  add_data
	  click_button submit }.not_to change(TempListing, :count)
      end
    end

    describe "Create with valid information" do
      it "Adds a new listing w/o price" do
        expect{
		add_data_w_photo
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should_not have_content "Price:" 
      end	      

      it "Adds a new listing w price" do
        expect{
		add_data_w_photo
                fill_in 'Price', with: "150.00"
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Price: $150.00" 
      end	      

      it "Adds a new listing w compensation" do
        expect{
		add_data_w_photo
                select('Jobs', :from => 'temp_listing_category_id')
                fill_in 'salary', with: "Competitive"
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Compensation: Competitive" 
        page.should_not have_content "Price:" 
      end	      

      it "Adds a new listing w event" do
        expect{
		add_data_w_photo
                fill_in 'Price', with: "150.00"
                select('Event', :from => 'temp_listing_category_id')
                fill_in 'start-date', with: Date.today().strftime('%m/%d/%Y')
                fill_in 'end-date', with: Date.today().strftime('%m/%d/%Y')
		select('15:00', :from => 'start-time')
		select('20:00', :from => 'end-time')
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Start Date: "
        page.should have_content "End Date: "
        page.should have_content "Start Time: "
        page.should have_content "End Time: "
        page.should_not have_content "Compensation: Competitive" 
        page.should have_content "Price:" 
      end	      
    end	      
  end

  describe "Edit Invalid Temp Pixi" do 
    let(:temp_listing) { FactoryGirl.create(:temp_listing) }
    before { visit edit_temp_listing_path(temp_listing) }

    it { should have_selector('.sm-thumb') }
    it { should have_selector('#photo') }
    it { should have_link 'Cancel', href: listings_path }
    it { should have_button 'Next' }

    it "empty title should not change a listing" do
      expect { 
	      fill_in 'Title', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content "Title can't be blank"
      page.should have_content 'Build Pixi'
    end

    it "empty description should not change a listing" do
      expect { 
	      fill_in 'Description', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content "Description can't be blank"
      page.should have_content 'Build Pixi'
    end

    it "invalid price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '$500'
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content 'Build Pixi'
      page.should have_content "Price is not a number"
    end

    it "huge price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '5000000'
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content 'Build Pixi'
    end

    it "should not add a large pic" do
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo2.png"))
              click_button submit
      }.not_to change(temp_listing.pictures,:count).by(-1)

      page.should have_content 'Build Pixi'
    end

    it "should not delete last picture from listing", js: true do
      expect { 
	      click_remove_ok; sleep 4
      }.not_to change(temp_listing.pictures,:count).by(-1)

      page.should have_content 'Pixi must have at least one image'
    end
  end

  describe "Edit Temp Pixi" do 
    let(:temp_listing) { FactoryGirl.create(:temp_listing_with_pictures) }
    before { visit edit_temp_listing_path(temp_listing) }

    it { should have_selector('.sm-thumb') }
    it { should have_selector('#photo') }
    it { should have_button 'Next' }

    it "Changes a pixi title" do
      expect{
	      fill_in 'Title', with: "Guitar for Sale"
              click_button submit
      }.to change(TempListing,:count).by(0)

      page.should have_content "Guitar for Sale"
      page.should have_content 'Review Your Pixi'
    end

    it "Changes a pixi description" do
      expect{
	      fill_in 'Description', with: "Acoustic bass"
              click_button submit
      }.to change(TempListing,:count).by(0)

      page.should have_content 'Review Your Pixi'
      page.should have_content "Acoustic bass" 
    end

    it "Adds a pixi pic" do
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
              click_button submit
      }.to change(temp_listing.pictures,:count).by(1)

      page.should have_content 'Review Your Pixi'
    end

    it "Cancels build pixi", js: true do
      expect{
         click_remove_ok
      }.to change(TempListing,:count).by(0)

      page.should have_content "Pixis" 
    end

    it "should cancel delete picture from listing", js: true do
      click_remove_cancel
      page.should have_content 'Build Pixi'
    end

    it "should delete picture from listing", js: true do
      expect{
        click_remove_ok; sleep 2
      }.to change(Picture,:count).by(-1)

      page.should have_content 'Build Pixi'
    end

    it "Cancels build cancel", js: true do
      click_remove_cancel
      page.should have_content "Build Pixi" 
    end

    it "Changes a pixi price" do
      expect{
              fill_in 'Price', with: nil
              click_button submit
      }.to change(TempListing,:count).by(0)

      page.should have_content 'Review Your Pixi'
    end
  end

  describe 'Reviews a Pixi' do
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id, status: 'new') }
    before { visit temp_listing_path(temp_listing) }

    it { should have_content "Posted By: #{temp_listing.seller_name}" }
    it { should_not have_selector('#contact_content') }
    it { should_not have_selector('#comment_content') }
    it { should_not have_link 'Follow', href: '#' }
    it { should have_link 'Prev', href: edit_temp_listing_path(temp_listing) }
    it { should have_link 'Remove', href: temp_listing_path(temp_listing) }
    it { should have_button 'Next' }
    it { should have_content "ID: #{temp_listing.pixi_id}" }
    it { should have_content "Posted: #{get_local_time(temp_listing.start_date)}" }
    it { should have_content "Updated: #{get_local_time(temp_listing.updated_at)}" }

    it { should have_content temp_listing.title }

    it "cancel remove pixi", js: true do
      click_remove_cancel
      page.should have_content "Review Your Pixi" 
    end

    it "deletes a pixi", js: true do
      expect{
        click_remove_ok; sleep 3;
      }.to change(TempListing,:count).by(-1)

      page.should have_content "Pixis" 
      page.should_not have_content temp_listing.title
    end

    it "submits a pixi" do
      expect { 
	      click_button submit
	}.not_to change(TempListing, :count)

      page.should have_content "Submit Your Order" 
    end

    it "goes back to build a pixi" do
      expect { 
	      click_link 'Prev'
	}.not_to change(TempListing, :count)

      page.should have_content "Build Pixi" 
    end
  end

  describe 'Reviews active Pixi', js: true do
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id, status: 'edit') }
    before { visit temp_listing_path(temp_listing) }

    it "cancels review of active pixi" do
      click_cancel_cancel
      page.should have_content "Review Your Pixi" 
    end

    it "cancels pixi review" do
      click_cancel_ok; sleep 2
      page.should have_content "Pixis" 
    end
  end
end