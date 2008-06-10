class Space < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships, 
    :select => 'users.*, memberships.role AS role'
  has_many :assets, :conditions => 'parent_id IS NULL'
  has_many :assets_with_thumbnails, :class_name => 'Asset'
  has_many :pages, :extend => ActiveRecord::Acts::DottedPath::AssociationExtension
  has_many :plugins
  has_many :domains
  
  cattr_accessor :active
  
public  
  # Returns the given user's role for this site
  def role(user=nil)
    (self[:role] ||= self.memberships.role(self, user)).to_i
  end
  
  # Retrieves the default page for this space
  def default_page
    pages.find_by_is_default(true)
  end
  
  # Returns all available plugins
  def available_plugins
    Slate.plugins.collect do |plugin|
      plugins.detect { |e| e.key == plugin.key } || 
        plugins.build(:slate_plugin => plugin, :key => plugin.key)
    end
  end
  
  # Updates plugins associated with this space
  def plugins=(keys=[])
    # Enables available plugins that are named in the keys parameter
    # Disables available plugins that are absent
    available_plugins.each do |plugin|    
      keys.include?(plugin.key) ? plugin.enable! : plugin.disable!
    end
  end
end