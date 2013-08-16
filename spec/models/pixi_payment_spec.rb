require 'spec_helper'

describe PixiPayment do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user, email: "jblow123@pixitest.com") 
    @buyer = FactoryGirl.create(:pixi_user, first_name: 'Jaine', last_name: 'Smith', email: 'jaine.smith@pixitest.com') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id)
    @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
    @txn = @user.transactions.create FactoryGirl.attributes_for(:balanced_transaction)
    @invoice = @user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, transaction_id: @txn.id)
    @payment = @invoice.pixi_payments.build FactoryGirl.attributes_for(:pixi_payment, pixi_id: @listing.pixi_id, buyer_id: @buyer.id,
      transaction_id: @txn.id, seller_id: @user.id, amount: @invoice.amount)
  end

  subject { @payment }

  it { should respond_to(:pixi_id) }
  it { should respond_to(:buyer_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:transaction_id) }
  it { should respond_to(:invoice_id) }
  it { should respond_to(:pixi_fee) }
  it { should respond_to(:amount) }
  it { should respond_to(:token) }
  it { should respond_to(:confirmation_no) }

  it { should respond_to(:seller) }
  it { should respond_to(:buyer) }
  it { should respond_to(:listing) }
  it { should respond_to(:transaction) }
  it { should respond_to(:invoice) }
  
  it { should be_valid }

  describe "when seller_id is empty" do
    before { @payment.seller_id = "" }
    it { should_not be_valid }
  end

  describe "when seller_id is entered" do
    before { @payment.seller_id = 1 }
    it { @payment.seller_id.should == 1 }
  end
  
  describe "when buyer_id is empty" do
    before { @payment.buyer_id = "" }
    it { should_not be_valid }
  end

  describe "when buyer_id is entered" do
    before { @payment.buyer_id = 1 }
    it { @payment.buyer_id.should == 1 }
  end
  
  describe "when pixi_id is empty" do
    before { @payment.pixi_id = "" }
    it { should_not be_valid }
  end

  describe "when pixi_id is entered" do
    before { @payment.pixi_id = "1" }
    it { @payment.pixi_id.should == "1" }
  end
  
  describe "when invoice_id is empty" do
    before { @payment.invoice_id = "" }
    it { should_not be_valid }
  end

  describe "when invoice_id is entered" do
    it { @payment.invoice_id.should == @invoice.id }
  end
  
  describe "when transaction_id is empty" do
    before { @payment.transaction_id = "" }
    it { should_not be_valid }
  end

  describe "when transaction_id is entered" do
    before { @payment.transaction_id = 1 }
    it { @payment.transaction_id.should == 1 }
  end
  
  describe "when pixi_fee is a number" do
    before { @payment.pixi_fee = 50.00 }
    it { @payment.pixi_fee.should == 50.00 }
  end
  
  describe "when pixi_fee is empty" do
    before { @payment.pixi_fee = "" }
    it { should_not be_valid }
  end
  
  describe "when amount is a number" do
    before { @payment.amount = 50.00 }
    it { should be_valid }
  end
  
  describe "when amount is empty" do
    before { @payment.amount = "" }
    it { should_not be_valid }
  end

  describe "when token is not a number" do
    before { @payment.token = "xx00" }
    it { should be_valid }
  end
  
  describe "when token is empty" do
    before { @payment.token = "" }
    it { should_not be_valid }
  end
  
  describe 'add_transaction' do
    it { PixiPayment.add_transaction(@invoice, 0.99, @txn.token).should be_true }
    it { PixiPayment.add_transaction(@invoice, 0.99, nil).should_not be_true }
  end
end