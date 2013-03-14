class Listing < ListingParent
  self.table_name = "listings"

  before_create :activate

  attr_accessor :parent_pixi_id

  has_many :posts, :dependent => :destroy
  has_many :site_listings, :dependent => :destroy
  #has_many :sites, :through => :site_listings, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  # set active status
  def activate
    if self.status != 'sold'
      self.status, self.start_date = 'active', Time.now 
      set_end_date
    end
    self
  end

  # check for free pixi posting
  def self.free_order? val
    active.get_by_site(val).count < SITE_FREE_AMT ? true : false rescue nil
  end
end
