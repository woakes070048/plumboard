class EventType < ActiveRecord::Base
  attr_accessible :code, :description, :hide, :status
  
  validates :description, :presence => true
  validates :status, :presence => true
  validates :code, :presence => true
  validates :hide, :presence => true
  
  has_many :listings, foreign_key: 'event_type_code', primary_key: 'code'
  has_many :temp_listings, foreign_key: 'event_type_code', primary_key: 'code'
  
  # return active types
  def self.active
    where(:status => 'active')
  end
end
