class Space < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships, 
    :select => 'users.*, memberships.role AS role'
  has_many :assets, :conditions => 'parent_id IS NULL'
  has_many :assets_with_thumbnails, :class_name => 'Asset'
  has_many :pages, :extend => ActiveRecord::Acts::DottedPath::AssociationExtension
    
  cattr_accessor :active
public  
  # returns the given user's role for this site
  def role(user=nil)
    (self[:role] ||= self.memberships.role(self, user)).to_i
  end
  
  # retrieves the default page for this space
  def default_page
    pages.find_by_is_default(true)
  end
end