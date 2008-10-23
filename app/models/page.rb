class Page < ActiveRecord::Base
  # Acts
  acts_as_dotted_path :scope => :space_id, 
    :ensure_root => true, :order => 'path, position ASC'

  # Associations
  belongs_to :behavior, :polymorphic => true
  belongs_to :space
  has_many :areas
  has_many :permalinks, :as => :permalinkable

  # Associated saves
  associated_save :permalinks  

  # Attributes
  alias_attribute :default, :is_default
  alias_attribute :hidden, :is_hidden

  # Callbacks
  before_validation :ensure_name
  after_save :ensure_one_default_page

  # Validations
  validates_presence_of :space_id
  validates_presence_of :name

protected
  # Callback which ensures that the root node 
  # has the name 'Pages'
  def ensure_name
    self.name = 'Pages' if self.root?
  end
  
  # Callback which ensures that only one 
  # default page exists for this page's space
  def ensure_one_default_page
    return unless is_default?
    self.class.update_all(['is_default = ?', false], ['is_default = ? AND id != ?', true, id])
  end

  # Callback from acts_as_dotted_path which is invoked
  # before automatically creating a root node (when 
  # ensure_root option is true)
  def before_root(page)
    self.space_id = page.space_id
  end
  
public
  def self.find_by_permalink(permalink)
    Permalink.with_type('Page').first(:conditions => { 
      :name => (permalink||'').join('/') 
    }).try(:permalinkable)
  end
  
  def permalink
    permalinks.primary.first || permalinks.first
  end
  
  # Returns the names of all items in the bloodline
  # (except the root page)
  def path_names
    bloodline[1..-1].map(&:name)
  end
  
  # Returns the url path to this page
  def url
    bloodline[1..-1].map(&:permalink)
  end
  
  # Custom collection which returns areas for page
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
  
  # Retrieves content for given key with options
  def content_for(key, mode=:draft)
    conditions = [['`key` = ?'], key.to_s]
    conditions.first << '`version` = 0' if mode == :draft
    conditions.first << '`version` = 1' if mode == :production
    conditions[0] = conditions[0].join(' AND ')
    
    areas_with_default(conditions).first || areas.build(:key => key.to_s)
  end
end