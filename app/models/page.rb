class Page < ActiveRecord::Base
  permalink_column :name, :glue => '_'
  acts_as_dotted_path :scope => :space_id, :ensure_root => true, :order => 'path, position ASC'
  belongs_to :space
  
  has_many :areas
  
  validates_presence_of :space_id
  validates_presence_of :name

  before_validation :ensure_name
  before_save :ensure_one_default_page
  
protected
  # ensures that the root node has the name
  # "Pages"
  def ensure_name
    self.name = 'Pages' if self.root?
  end
  
  # ensures that only one default page exists
  # for this page's space
  def ensure_one_default_page
    return unless is_default?
    return unless default_page = space.default_page
    default_page.update_attribute(:is_default, false)
  end

  # callback from acts_as_dotted_path which is invoked
  # before automatically creating a root node (when 
  # ensure_root option is true)
  def before_root(page)
    self.space_id = page.space_id
  end
  
public
  # returns the names of all items in the bloodline
  # (except the root page)
  def path_names
    bloodline[1..-1].map(&:name)
  end
  
  # alias to is_default?
  def default?
    is_default?
  end
  
  # alias to is_hidden?
  def hidden?
    is_hidden?
  end

  # custom collection which returns areas for page
  # as well as areas marked as default
  def areas_with_default(conditions=nil)
    Area.send(:with_scope, :find => { :conditions => conditions}) do
      Area.find(:all, :select => 'a.*', 
        :from => 'areas a INNER JOIN pages p ON p.id=a.page_id',
        :conditions => ['(p.id = ? OR (p.space_id = ? AND a.is_default = ?))',
          id, space_id, true],
        :order => 'a.is_default ASC')
    end      
  end
  
  # retrieves content for given key with options
  def content_for(key, mode=:draft)
    conditions = [['key = ?'], key.to_s]
    conditions.first << 'version = 0' if mode == :draft
    conditions.first << 'version = 1' if mode == :production
    conditions[0] = conditions[0].join(' AND ')
    
    areas_with_default(conditions).first || areas.build(:key => key.to_s)
  end
end