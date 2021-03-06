require 'spec_helper'

feature 'Favorite Sellers' do
  subject { page }

  let(:user) { create :contact_user }
  let(:seller) { create :contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music' }

  def test_navbar(page_name, status)
    ftype = page_name == 'My Followers' ? 'seller' : 'buyer'
    user_id = page_name == 'My Followers' ? seller.id : nil
    expect(page).to have_content page_name
    expect(page).to have_link 'Followed', href: favorite_sellers_path(ftype: ftype,
      id: user_id, status: 'active'), class: (status == 'active' ? 'active' : '')
    expect(page).to have_link 'Unfollowed', href: favorite_sellers_path(ftype: ftype,
      id: user_id, status: 'removed'), class: (status == 'removed' ? 'active' : '')
  end

  describe 'My Followers' do
    def test_table(usr, has_addr=false)
      addr = has_addr ? usr.primary_address : usr.home_zip
      expect(page).to have_content 'User Name'
      expect(page).to have_content 'Location'
      expect(page).to have_content 'Follow Date'
      expect(page).to have_css 'img'
      expect(page).to have_content usr.name
      expect(page).to have_content addr
      expect(page).to have_content Date.today.strftime('%m/%d/%Y')
    end

    before :each do
      init_setup user
    end

    it 'renders Followed' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      test_navbar('My Followers', 'active')
      test_table(user)
      expect(page).to have_content 'Displaying ' << FavoriteSeller.count.to_s << ' followers'
    end

    it 'renders Unfollowed' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'removed'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'removed')
      test_navbar('My Followers', 'removed')
      test_table(user)
      expect(page).to have_content 'Displaying ' << FavoriteSeller.count.to_s << ' followers'
    end

    it 'renders "No sellers found" if no sellers' do
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      test_navbar('My Followers', 'active')
      expect(page).to have_content 'No followers found.'
    end

    it 'splits more than 15 entries into separate pages' do
      15.times do
        @follower = create :contact_user
        create :favorite_seller, user_id: @follower.id, seller_id: seller.id, status: 'active'
      end
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      user.update_attribute(:last_name, 'Zywiec')    # user must appear last in alphabetical order
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      expect(page).to have_content 'Displaying followers'
      expect(page).to have_selector('div.pagination')
      click_link '2'
      test_navbar('My Followers', 'active')
      test_table(user)
    end

    it 'displays follower address if available' do
      user.contacts.create
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      test_navbar('My Followers', 'active')
      test_table(user, true)
    end
  end

  describe 'Manage Followers' do
    def test_table(has_addr=false)
      addr = has_addr ? seller.primary_address : seller.home_zip
      expect(page).to have_content 'Seller Name'
      expect(page).to have_content 'Location'
      expect(page).to have_content '# Pixis'
      expect(page).to have_content '# Followers'
      expect(page).to have_css 'img'
      expect(page).to have_content seller.business_name
      expect(page).to have_content addr
      expect(page).to have_content seller.listings.count
      expect(page).to have_content seller.followers.where(status: 'active').count
      expect(page).to have_content('View')
    end

    before :each do
      init_setup user
    end

    it 'renders Followed' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      test_navbar('Manage Followers', 'active')
      test_table
      expect(page).to have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders Unfollowed' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'removed'
      visit favorite_sellers_path(ftype: 'buyer', status: 'removed')
      test_navbar('Manage Followers', 'removed')
      test_table
      expect(page).to have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders "No sellers found" if no sellers' do
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      test_navbar('Manage Followers', 'active')
      expect(page).to have_content 'No followed sellers found.'
    end

    it 'splits more than 15 entries into separate pages' do
      ('a'..'z').each do |char|
        business = create :contact_user, user_type_code: 'BUS', business_name: 'business ' + char
        create :favorite_seller, user_id: user.id, seller_id: business.id, status: 'active'
      end
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      expect(page).to have_content 'Displaying sellers'
      expect(page).to have_selector('div.pagination')
      click_link '2'
      test_navbar('Manage Followers', 'active')
      test_table
    end

    it 'displays seller address if available' do
      seller.contacts.create
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      test_navbar('Manage Followers', 'active')
      test_table(true)
    end
  end
end
