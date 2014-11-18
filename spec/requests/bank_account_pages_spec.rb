require 'spec_helper'

feature "BankAccounts" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user, first_name: 'Jack', last_name: 'Snow', email: 'jack.snow@pixitest.com') }

  def add_data
    fill_in 'routing_number', with: '021000021'
    fill_in 'acct_number', with: 9900000002
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    select("checking", :from => "bank_account_acct_type")
  end

  def change_data
    fill_in 'acct_number', with: 9900000004
    fill_in 'bank_account_acct_name', with: "Personal Business"
  end

  def balanced
    @api_key = Balanced::ApiKey.new.save
    Balanced.configure @api_key.secret
  end

  def invalid_acct
    fill_in 'routing_number', with: '100000007'
    fill_in 'acct_number', with: 8887776665555
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    select("checking", :from => "bank_account_acct_type")
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
  end

  def submit_invalid_acct
    expect {
      find('#bank-btn').click; sleep 3;
    }.to change(BankAccount, :count).by(0)

    page.should_not have_content 'Bill To'
    page.should have_content 'Account #'
    page.should_not have_content 'Successfully'
  end

  describe "Create Bank Account" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      visit root_path
      click_link 'My Accounts'
      add_data
    end

    it "shows content" do
      page.should have_content('Setup Your Payment Account')
      page.should have_content("Account #")
      page.should have_button("Save")
    end

    it "creates an new account" do
      expect {
          click_on 'Save'; sleep 3;
      }.to change(BankAccount, :count).by(1)

      # page.should_not have_content 'Pixis'
      page.should have_content 'Account #'
    end
  end

  describe "Delete Bank Account" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
      visit root_path
      click_link 'My Accounts'
    end

    it "shows content" do
      page.should have_content('Your Payment Account')
      page.should have_content("Account #")
      page.should have_link("Remove", href: bank_account_path(@account))
    end

    it "removes an account" do
      BankAccount.any_instance.stub(:delete_account).and_return(true)
      expect {
          click_on 'Remove'; sleep 3;
      }.to change(BankAccount, :count).by(0)

      page.should have_content 'Pixis'
      page.should_not have_content 'Account #'
    end
  end

  describe "Create Bank Account - Bill" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      visit root_path
      click_link 'Bill'
      add_data
    end

    it "shows content" do
      page.should have_content('Setup Your Payment Account')
      page.should have_content("You need to setup a bank account")
      page.should have_content("Account #")
      page.should have_button("Next")
    end

    it "creates an new account" do
      expect {
          click_on 'Next'; sleep 3;
      }.to change(BankAccount, :count).by(1)

      page.should have_content 'My Invoices'
      page.should_not have_content 'Account #'
    end
  end

  describe "Create Invoice Bank Account" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    end

    describe 'visit create page', js: true do
      before do
        visit new_bank_account_path(target: 'shared/invoice_form')
        add_data
      end

      it "shows content" do
        page.should have_content('Setup Your Payment Account')
        page.should have_content("Account #")
        page.should have_button("Next")
      end

      it "creates an new account" do
        expect {
            click_on 'Next'; sleep 3;
          }.to change(BankAccount, :count).by(1)
        page.should have_content 'Bill To'
        page.should_not have_content 'Account #'
      end

      it "attempts to create an invalid account" do
        fill_in 'bank_account_acct_name', with: ""
	submit_invalid_acct

        fill_in 'acct_number', with: ""
	submit_invalid_acct

        fill_in 'routing_number', with: ""
	submit_invalid_acct

        fill_in 'routing_number', with: "100000007"
	submit_invalid_acct
      end
    end
  end
end
