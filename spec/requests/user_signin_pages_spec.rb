require 'spec_helper'

feature "UserSignins" do
  let(:submit) { "Sign in" }
  let(:site) { FactoryGirl.create :site }
  subject { page }

  def invalid_login
    fill_in "user_email", :with => "notarealuser@example.com"
    fill_in "pwd", :with => "fakepassword"
    click_button submit
  end

  def about_menu
    page.should have_link('About', href: about_path)
    page.should have_link('Contact', href: contact_path)
    page.should have_link('Privacy', href: privacy_path)
    page.should have_link('Terms', href: terms_path )
    page.should have_link('Help', href: help_path )
  end

  describe 'home page' do 
    before do 
      add_region
      @user = FactoryGirl.create :pixi_user, confirmed_at: Time.now 
      visit new_user_session_path
    end

    it "signs in a registered user" do
      set_const 0
      user_login @user
      expect(Listing.get_by_site(@loc, 1).size).to eq(1)
      expect(Listing.get_by_city(nil, @loc).size).to eq(1)
      page.should have_content "Home"
    end

    it "signs in a registered user with local pixi home" do
      set_const 500
      user_login @user
      page.should_not have_content "Home"
      page.should have_content "Pixis"
    end

    it "does not sign in a unregistered user" do
      invalid_login
      page.should_not have_content "Home"
      page.should_not have_content "Pixis"
      page.should have_content "Sign in"
    end
  end

  describe 'sign in modal' do
    before :each do
      visit root_path 
      @user = FactoryGirl.create :pixi_user, confirmed_at: Time.now 
    end

    it 'shows content' do
      click_link 'Login'; sleep 2
      check_page_selectors ['#pwd, #login-btn, #fb-btn'], true, false
      user_login @user
      page.should have_content(@user.first_name)
      page.should_not have_content('Manage')
      page.should_not have_content('Setup Your Payment Account')
      page.should have_link('Sign out', href: destroy_user_session_path)
    end

    it "does not sign in a unregistered user" do
      invalid_login
      page.should_not have_content "Home"
      page.should_not have_content "Pixis"
      page.should have_content "Sign in"
    end
  end

  describe 'sign in modal - business' do
    before :each do
      visit root_path 
      @user = FactoryGirl.create :business_user, confirmed_at: Time.now 
    end
    
    def bus_login txt, val
      click_link 'Login'; sleep 2
      check_page_selectors ['#pwd, #login-btn, #fb-btn'], true, false
      user_login @user
      page.should have_content(@user.first_name)
      page.should_not have_content('Manage')
      page.send(txt, have_content('Setup Your Payment Account'))
      page.send(val, have_content('You need to setup default preferences for your pixis.'))
      page.should have_link('Sign out', href: destroy_user_session_path)
    end

    context 'no bank acct' do
      it 'shows account content' do
        bus_login 'should', 'should_not'
      end
    end

    context 'has bank acct w/o prefs' do
      before do
        @user.bank_accounts.create attributes_for :bank_account
      end

      it 'shows account content' do
        bus_login 'should_not', 'should'
      end
    end

    context 'has bank acct w/ prefs' do
      before do
        @user.bank_accounts.create attributes_for :bank_account
	@user.preferences.first.update_attributes(fulfillment_type_code: 'A', sales_tax: 8.25, ship_amt: 9.99)
      end

      it 'shows account content' do
        bus_login 'should_not', 'should_not'
      end
    end
  end

  describe 'sign in page - other signins' do 
    before { visit new_user_session_path }

    it 'shows content' do
      page.should have_selector '#fb-btn' #, text: user_omniauth_authorize_path(:facebook)
      page.should have_button('Sign in')
      page.should have_link 'Sign up for free!', href: new_user_registration_path
    end

    describe 'facebook', fb: true do 
      before :each do
        create :state
        add_region
      end
      it_should_behave_like 'an omniauth login', 0, 'Home'
      it_should_behave_like 'an omniauth login', 500, 'Pixis'
    end

    describe 'registered unconfirmed users' do 
      before do
        @user = FactoryGirl.create :unconfirmed_user, confirmed_at: nil 
      end

      it "displays confirm message to a registered user" do
        user_login @user
        page.should have_content("You have to confirm your account before continuing") 
      end

      it "does not allow an unregistered user to sign in" do
        invalid_login
        page.should_not have_content("Signed in successfully")
      end
    end

    describe 'registered confirmed users', base: true do
      it_should_behave_like 'manage_signin_links', 'pixi_user', false, false, false, false
    end

    describe 'registered admin users', admin: true  do
      it_should_behave_like 'manage_signin_links', 'admin', true, true, false, true
    end

    describe 'registered editor users', base: true  do
      it_should_behave_like 'manage_signin_links', 'editor', true, true, false, true
    end

    describe 'registered pixter users', base: true  do
      it_should_behave_like 'manage_signin_links', 'pixter', false, true, false, true
    end

    describe 'registered subscriber users', base: true  do
      it_should_behave_like 'manage_signin_links', 'subscriber', false, false, false, false
    end

    describe 'registered business users', base: true  do
      it_should_behave_like 'manage_signin_links', 'contact_user', false, false, true, false
    end

    describe "displays my accounts link", base: true  do
      before(:each) do
        @user = FactoryGirl.create :subscriber, confirmed_at: Time.now 
        user_login @user
        FactoryGirl.create(:listing, seller_id: @user.id)
	@account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
	visit root_path
      end

      it 'shows content' do
        page.should have_content('My Accounts')
        page.should have_link('My Accounts', href: bank_account_path(@account))
      end
    end
  end
end
