require File.dirname(__FILE__) + '/abstract_unit'
require File.dirname(__FILE__) + '/../../dbstring/lib/dbstring.rb'

class Page < ActiveRecord::Base
  acts_as_dotted_path :order => 'position ASC, id'
  def <<(child)
    child = [child] unless child.is_a?(Array)
    child.each { |c| children << c }
  end
end

class Site < ActiveRecord::Base
  has_many :pages, :class_name => 'Tree'
end

class ActsAsDottedPathTest < Test::Unit::TestCase
  def setup
    create_fixtures :pages
    Page.delete_all
  end
  
  def create_page(options={})
    options = {:name => options} if options.is_a?(String)
    Page.create!(options)
  end
  
  def find_page(name)
    Page.find_by_name(name)
  end
  
  def assert_relationship(expected, parent, child)
    assert_equal(expected, parent.descendant?(child))
    assert_equal(expected, child.ancestor?(parent))
  end
  
  def test_creating_a_page
    page = Page.create!(:name => 'Home')
    assert_equal(1, Page.count())
    assert_equal(0, page.depth)
    assert_equal('', page.path)
    assert_equal(page.id.to_s, page.path_with_id)
  end
  
  def test_creating_a_child
    parent = Page.create!(:name => 'Home')
    child = Page.new(:name => 'Child')
    parent.children << child
    
    # assocation
    assert_equal(1, parent.children.count)
    
    # attributes
    # assert_equal(2, child.id)
    assert_equal(1, child.depth)
    assert_equal(parent.id.to_s, child.path)
    assert_equal("#{parent.id}.#{child.id}", child.path_with_id)
    
    # relationships
    assert_relationship(true, parent, child)
    assert_equal([parent], child.ancestors)
    assert_equal([parent,child], child.bloodline)
    assert_equal([child], parent.descendants)
  end
  
  def test_creating_a_relationship_via_parent_column
    parent = create_page('Parent')
    child = create_page(:name => 'Child', :parent_id => parent.id)
    assert_equal([child], parent.children)
    assert_equal(child.path, parent.path_with_id)
    assert_equal(child.depth, parent.depth + 1)
    assert_equal(child.parent_id, parent.id)
  end
  
  def test_counter_cache
    parent = create_page('Parent')
    assert_equal(0, parent[:children_count])
    
    child  = create_page(:name => 'Child', :parent_id => parent.id)
    parent.reload
    assert_equal(1, parent[:children_count])
  end
  
  def test_changing_parents
    parent = create_page('Biological')
    stepparent = create_page('Stepparent')
    child = create_page('Child')
    
    # create and verify parent/child relationship
    parent.children << child
    assert_relationship(true, parent, child)
    assert_relationship(false, stepparent, child)
    
    assert_equal(parent, child.parent)
    
    assert_equal(1, parent.children_count)
    assert_equal(0, stepparent.children_count)

    # change parent
    stepparent.children << child
    assert_relationship(false, parent, child)
    assert_relationship(true, stepparent, child)
    
    parent.reload
    stepparent.reload

    assert_equal(0, parent.children_count)
    assert_equal(1, stepparent.children_count)
  end
  
  def test_siblings
    dad    = create_page('Dad')
    mike   = create_page('Mike')
    jen    = create_page('Jen')
    chris  = create_page('Chris') 
    amanda = create_page('Amanda')
    
    # groupings
    children = [mike, jen, chris, amanda] 
    siblings = [mike, jen, amanda]
    
    # make children
    dad << children
    
    assert_equal(siblings, chris.siblings)
    assert_equal(children, chris.siblings(:self => true))
  end
  
  def test_full_hierarchy
    root = create_page('My Pages')
      people = create_page('People')    
      root << people
        people << create_page('Chris Scharf')
        people << create_page('Dave Olsen')
        people << create_page('Adam Glenn')
      projects = create_page('Projects')
      root << projects
        projects << create_page('WVU Downloads')  
        projects << create_page('The Question')  
        projects << create_page('slate')  
        projects << create_page('Textile Editor Helper')  
    
    # verify counts        
    assert_equal(2, root.children.count)      
    assert_equal(3, people.children.count)
    assert_equal(4, projects.children.count)
    assert_equal(9, root.descendants.length)
    
    assert_equal(2, root[:children_count])
    assert_equal(3, people[:children_count])
    assert_equal(4, projects[:children_count])
    
    # verify relationships
    chris = find_page('Chris Scharf')
    assert_equal(people, chris.parent)
    assert_equal(root, chris.parent.parent)
    assert_equal(true, chris.ancestor?(people))
    assert_equal(true, chris.ancestor?(root))
    
    slate = find_page('slate')
    assert_equal(projects, slate.parent)
    assert_equal(root, slate.parent.parent)
    assert_equal(true, slate.ancestor?(projects))
    assert_equal(true, slate.ancestor?(root))
    
    downloads = find_page('WVU Downloads')
    the_question = find_page('The Question')
    teh = find_page('Textile Editor Helper')
    assert_equal([downloads, the_question, slate, teh], slate.siblings(:self => true))
    
    assert_equal('My Pages > Projects > slate', slate.bloodline.map(&:name).join(' > '))
  end
  
  def test_remap_tree
    root   = create_page('My Pages')
    
    # create top level pages
    scharf = create_page('Chris Scharf')
    olsen  = create_page('Dave Olsen')
    glenn  = create_page('Adam Glenn')
    staff  = create_page('Staff')
    
    root.children << scharf
    root.children << olsen
    root.children << glenn
    root.children << staff
    
    assert_equal(4, root.children.length)
    assert_equal(0, staff.children.length)
    
    # remap
    mappings = []
    mappings << [staff.id, root.id]
    mappings << [glenn.id, staff.id]
    mappings << [olsen.id, staff.id]
    mappings << [scharf.id, staff.id]
    
    mappings_string = mappings.collect { |e| e.join('-') }.join(',')
    
    Page.remap_tree!(mappings_string)
    
    
    [root, staff, scharf, olsen, glenn].each { |e| e.reload }
    
    assert_equal(1, root.children.length)
    assert_equal(3, staff.children.length)
    
    assert_equal(1, staff.position)
    assert_equal(1, glenn.position)
    assert_equal(2, olsen.position)
    assert_equal(3, scharf.position)
    
    assert_equal([staff], root.children)
    assert_equal([glenn, olsen, scharf], staff.children)
  end
  
  def test_recount_children
    root   = create_page('My Pages')
    
    # create top level pages
    scharf = create_page('Chris Scharf')
    olsen  = create_page('Dave Olsen')
    glenn  = create_page('Adam Glenn')
    staff  = create_page('Staff')
    
    root.children  << staff
    staff.children << scharf
    staff.children << olsen
    staff.children << glenn
    
    assert_equal(1, root.children_count)
    assert_equal(3, staff.children_count)
    
    Page.update_all('children_count = 0')
    
    root.reload
    staff.reload
    
    assert_equal(0, root.children_count)
    assert_equal(0, staff.children_count)
    
    Page.recount_children!

    root.reload
    staff.reload

    assert_equal(root.children.size, root.children_count)
    assert_equal(staff.children.size, staff.children_count)
    
    assert_equal(1, root.children_count)
    assert_equal(3, staff.children_count)
  end
  
  def test_example_from_rdoc
    pages = Page.create!(:name => 'Pages')
    pages.children << Page.new(:name => 'Home')
    pages.children << Page.new(:name => 'About')
    pages.children << Page.new(:name => 'Projects')
    assert_equal(3, pages.children(true).size)
    
    projects = pages.children.find_by_name('Projects')
    projects.children << Page.new(:name => 'ActsAsDottedPath')
    
    # bloodline example
    p = projects.children.first # => 'ActsAsDottedPath' page
    assert_equal('Pages / Projects / ActsAsDottedPath', p.bloodline.map(&:name).join(' / '))

    # changing parents
    pages.children << p
    assert_equal('Pages / ActsAsDottedPath', p.bloodline.map(&:name).join(' / '))
    
    assert_equal(4, pages.children(true).size)
  end
end

class ActsAsDottedPathWithScopeTest < Test::Unit::TestCase
  def setup
    create_fixtures(:pages)
    Object.send(:remove_const, :Tree) if Object.const_defined?(:Tree)
    Object.const_set(:Tree, Class.new(ActiveRecord::Base))
    tree_class.set_table_name 'pages'
  end
  
  def tree_class
    @klass ||= Object.const_get(:Tree)
  end
  
  def create_node(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!({ :name => args.first })
    tree_class.create(options)
  end
  
  def assert_scope_condition(expected, object)
    assert_equal(expected, object.scope_condition)
  end  
  
  
  def test_default_scope_condition
    tree_class.acts_as_dotted_path
    root = create_node('root')
    
    assert_scope_condition('1 = 1', root)
  end
  
  def test_scope_condition_with_symbol
    tree_class.acts_as_dotted_path :scope => :site
    
    root = create_node('root', :site_id => 1)
    assert_scope_condition('site_id = 1', root)
    
    root = create_node('root', :site_id => 5)
    assert_scope_condition('site_id = 5', root)
  end
  
  def test_scope_condition_with_string
    tree_class.acts_as_dotted_path :scope => 'name = Chris'
    
    root = create_node('root')
    assert_scope_condition('name = Chris', root)
  end
  
  def test_scope_condition_with_string_interpolation
    tree_class.acts_as_dotted_path :scope => 'name = #{name}'
    
    root = create_node('Chris')
    assert_scope_condition('name = Chris', root)
  end
  
  def test_scope_condition_with_array
    tree_class.acts_as_dotted_path :scope => [:site, :other_id, 'name = "Chris"']
    
    root = create_node('root', :site_id => 31, :other_id => 77)
    assert_scope_condition('site_id = 31 AND other_id = 77 AND name = "Chris"', root)
  end
end

class ActsAsDottedPathWithBeforeRootTest < Test::Unit::TestCase
  def setup
    create_fixtures(:pages, :sites)
    Object.send(:remove_const, :Tree) if Object.const_defined?(:Tree)
    Object.const_set(:Tree, Class.new(ActiveRecord::Base))
    tree_class.set_table_name 'pages'
    tree_class.acts_as_dotted_path :scope => :site, :ensure_root => true
    
    tree_class.send(:define_method, :before_root) do |page|
      self.name = 'Page Root Node'
      self.site_id = page.site_id        
    end
    
    tree_class.delete_all
  end
  
  def tree_class
    @klass ||= Object.const_get(:Tree)
  end
  
  def create_node(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!({ :name => args.first })
    tree_class.create(options)
  end  

  def test_that_root_is_automatically_created
    page = create_node('Example page', :site_id => 77)
    assert_equal 2, tree_class.count
    
    root = tree_class.find(:first)
    assert_equal('Page Root Node', root.name)
    assert_equal(77, root.site_id)
  end
  
  def test_that_root_is_automatically_created_via_association
    site = Site.create!(:name => 'My Test Site')
    page = site.pages.create!(:name => 'Example page') 

    assert_equal 2, site.pages(true).count
    
    root = site.pages.find(:first)
    assert root.root?
    assert_equal('Page Root Node', root.name)
    assert_equal(site.id, root.site_id)
    assert_equal(root, page.parent)
  end
  
  def test_address_example
    site = Site.create!(:name => 'My Test Site')
    @wv = site.pages.create!(:name => 'WV')
    @morgantown = site.pages.create!(:name => 'Morgantown')
    @wv.children << @morgantown
    @address = site.pages.create!(:name => '1 Fine Arts Drive')
    @morgantown.children << @address
    
    @wv.reload; @morgantown.reload; @address.reload
    
    assert_equal(1, @wv.depth)
    assert_equal(2, @morgantown.depth)
    assert_equal(3, @address.depth)
    
    assert_equal(@morgantown, site.pages.find(:first, :conditions => 'name = "Morgantown" AND depth = 2'))
  end  
end