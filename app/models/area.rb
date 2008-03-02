class Area < ActiveRecord::Base
  compiled_column :body
  belongs_to :page
  belongs_to :user

  # Version 0 is draft, version 1 is published, 
  # versions 2-5 are previously published 
  has_many :versions, :class_name => 'Area', 
    :foreign_key => 'area_id', :dependent => :delete_all
  
  validates_presence_of :page_id
  validates_presence_of :user_id
  validates_presence_of :key

  before_validation :ensure_user

protected  
  # Ensures that user is set
  def ensure_user  
    self.user = User.active
  end
  
  # Increments all versions of this area
  def increment_versions
    self.class.update_all 'version = version + 1', 
      "area_id = #{self.id} AND version > 0"
  end

  # Removes old versions (any version >= 5) of this area
  def clear_old_versions
    self.class.delete_all "version >= 5 AND area_id = #{self.id}"
  end
    
public
  # Finds area with key in given space that is marked
  # as default (if any)
  def self.default_content_for(space_id, key)
    find_by_sql(['SELECT a.* FROM areas a INNER JOIN pages p on p.id=a.page_id ' +
      'WHERE a.key = ? AND (p.space_id = ? AND a.is_default = ?) ' +
      "ORDER BY a.is_default ASC", key, space_id, true]).first
  end

  # Publishes this area
  def publish!
    return false if new_record?
    
    returning self.clone do |published_area|
      transaction do
        increment_versions 
        clear_old_versions
        published_area.update_attributes(
          :area_id => self.id, :version => 1, :published_on => Time.now)
      end
    end  
  end

  # Finds currently published version
  def published_version
    versions.find_by_version(1)
  end 

  # Returns key for URL parameter
  def to_param
    self.key
  end
  
  # Returns custom DOM ID
  def dom_id
    ['area', page_id, key].join('-')
  end
  
  # Returns true if the area is marked as default
  # and, optionally, if the given page is the associated 
  # page for this area
  def default?(page=nil)
    return false unless is_default?
    return true if page.nil?
    self.page == page
  end

  # Returns true if given area is default
  # but not associated with given page
  def using_default?(page)
    return false unless is_default?
    self.page != page
  end
  
  # Marks this area as default
  def mark!
    self.class.default_content_for(page.space_id, self.key).try(:unmark!)

    save if new_record?    
    self.class.update_all(['is_default = ?', true], 
      ['area_id = ? OR id = ?', self.id, self.id])
    self.is_default = true
  end
  
  # Unmarks this area as default
  def unmark!
    save if new_record?
    self.class.update_all(['is_default = ?', false], 
      ['area_id = ? OR id = ?', self.id, self.id])
    self.is_default = false
  end  
  
  # toggles the default status 
  # (note that Rails already has a toggle! method,
  # so this implementation uses that)
  def toggle!(attr=nil)
    attr.nil? ? (default? ? unmark! : mark!) : super
  end
end