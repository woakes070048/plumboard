require 'spec_helper'

shared_examples 'create_bank_account_page' do |factory, val, val2, flg|
  describe "Create Bank Account" do 
    before :each do
      px_user = create factory.to_sym
      init_setup px_user
      @listing = create(:listing, seller_id: @user.id) 
      @user.preferences.first.update_attributes(fulfillment_type_code: 'A', sales_tax: 8.25, ship_amt: 9.99) if flg && @user.is_business?
      visit new_bank_account_path
    end

    it "shows content" do
      page.should have_content('Setup Your Payment Account')
      page.should have_content("Account #")
      page.should have_button("Save")
    end

    it "creates an new account" do
      expect {
          add_bank_data
          click_on 'Save'; sleep 3;
      }.to change(BankAccount, :count).by(1)

      page.send(val, have_content('Delivery Type'))
      page.send(val, have_content('Sales Tax'))
      page.send(val2, have_content('Your Payment Account'))
      page.send(val2, have_content('Account #'))
    end
  end
end
