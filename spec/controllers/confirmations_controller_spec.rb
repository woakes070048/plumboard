require 'spec_helper'

describe ConfirmationsController do

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def do_post
    post :create, :user => {'first_name'=>'test', 'last_name' => 'test', email: 'email@test.com'}
  end

  describe "POST create" do
    before :each do
      @user = stub_model(User)
      allow(User).to receive_message_chain(:where, :first).and_return(@user)
      allow(@user).to receive_message_chain(:confirmed_at, :nil?).and_return(true)
      mailer = double(UserMailer)
      allow(UserMailer).to receive(:confirmation_instructions).with(@user).and_return(mailer)
      allow(mailer).to receive(:deliver_later)
      allow(@user).to receive(:email).and_return('email@test.com')
      do_post
    end

    context 'success' do
      it "should assign @user" do
        expect(assigns(:user)).not_to be_nil
      end

      it "renders home page" do
        expect(response).to be_redirect
      end
    end

    context 'failure' do
      it "should render the next page" do
        expect(response).to be_redirect
      end
    end

  end

end
