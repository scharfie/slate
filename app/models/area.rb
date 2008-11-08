class Area < ActiveRecord::Base
  # Acts
  acts_as_published
  compiled_column :body

  # Associations
  belongs_to :page
  belongs_to :user

  # Callbacks
  before_validation :ensure_user

  # Validations
  validates_presence_of :page_id
  validates_presence_of :user_id
  validates_presence_of :key

protected  
  # Ensures that user is set
  def ensure_user  
    self.user = User.active
  end
    
public
  # Finds area with key in given space that is marked
  # as default (if any)
  def self.default_content_for(space_id, key)
    find_by_sql(['SELECT a.* FROM areas a INNER JOIN pages p on p.id=a.page_id ' +
      'WHERE a.key = ? AND (p.space_id = ? AND a.is_default = ?) ' +
      "ORDER BY a.is_default ASC", key, space_id, true]).first
  end

  # Returns key for URL parameter
  def to_param
    key
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