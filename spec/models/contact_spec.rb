require 'spec_helper'

describe Contact do
  before(:each) do
    @contact = FactoryGirl.build(:contact) 
  end

  it { is_expected.to respond_to(:address) }
  it { is_expected.to respond_to(:address2) }
  it { is_expected.to respond_to(:city) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:zip) }
  it { is_expected.to respond_to(:county) }
  it { is_expected.to respond_to(:work_phone) }
  it { is_expected.to respond_to(:home_phone) }
  it { is_expected.to respond_to(:mobile_phone) }
  it { is_expected.to respond_to(:website) }
  it { is_expected.to respond_to(:country) }
  it { is_expected.to respond_to(:lng) }
  it { is_expected.to respond_to(:lat) }
  it { is_expected.to respond_to(:contactable) }
  it { is_expected.to validate_length_of(:zip).is_at_least(5).is_at_most(15) }
  it { is_expected.to validate_length_of(:home_phone).is_at_least(10).is_at_most(15) }
  it { is_expected.to validate_length_of(:mobile_phone).is_at_least(10).is_at_most(15) }
  it { is_expected.to validate_length_of(:work_phone).is_at_least(10).is_at_most(15) }

  it { is_expected.to allow_value(4157251111).for(:home_phone) }
  it { is_expected.to allow_value(4157251111).for(:work_phone) }
  it { is_expected.to allow_value(4157251111).for(:mobile_phone) }
  it { is_expected.not_to allow_value(7251111).for(:home_phone) }
  it { is_expected.not_to allow_value(7251111).for(:work_phone) }
  it { is_expected.not_to allow_value(7251111).for(:mobile_phone) }
  it { is_expected.not_to allow_value(4157251111234567).for(:mobile_phone) }
  it { is_expected.to allow_value(41572).for(:zip) }
  it { is_expected.not_to allow_value(725).for(:zip) }

  describe "when city is invalid" do
    before { @contact.city = "@@@@" }
    it { is_expected.not_to be_valid }
  end

  describe "when city is empty" do
    before { @contact.city = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when state is empty" do
    before { @contact.state = "" }
    it { is_expected.not_to be_valid }
  end

  describe "full address" do
    it 'has address' do
      addr = [@contact.address, @contact.city, @contact.state].compact.join(', ') + ' ' + [@contact.zip, @contact.country].compact.join(', ')
      expect(@contact.full_address).to eq(addr)
    end

    it 'has no address' do
      @contact.address = @contact.city = @contact.state = @contact.zip = @contact.country = nil
      expect(@contact.full_address).to be_empty
    end
  end

  describe 'get_sites' do
    it 'locates sites' do
      @site = create :site, name: 'Detroit', site_type_code: 'city'
      @site1 = create :site, name: 'Detroit City College', site_type_code: 'school'
      @site2 = create :site, name: 'Greektown', site_type_code: 'area'
      @site.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: '1000 Michigan Ave', city: 'Detroit', state: 'MI'
      @site2.contacts.create FactoryGirl.attributes_for :contact, address: '100 State', city: 'Detroit', state: 'MI', zip: '48214'
      expect(Contact.get_sites('Detroit', 'MI').count).to eq(3)
    end

    it 'does not locate sites' do
      expect(Contact.get_sites('Detroit', 'MI').count).to eq(0)
    end
  end

  describe 'proximity' do
    it 'locates sites' do
      @site = create :site, name: 'Oakland', site_type_code: 'city'
      @site1 = create :site, name: 'Oakland City College', site_type_code: 'school'
      @site2 = create :site, name: 'Lake Merritt', site_type_code: 'area'
      @site.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Oakland', state: 'CA'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: '1000 Grant Ave', city: 'Oakland', state: 'CA'
      @site2.contacts.create FactoryGirl.attributes_for :contact, address: '100 Webster', city: 'Oakland', state: 'CA', zip: '94601'
      expect(Contact.proximity(nil, 25, [1, 1], true).count).to eq(0)
    end

    it 'does not locate sites' do
      expect(Contact.proximity(nil, 25, 'Detroit, MI', false).count).to eq(0)
    end
  end

end
