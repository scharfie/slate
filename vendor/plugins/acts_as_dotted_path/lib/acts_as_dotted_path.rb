if __FILE__ == $0
  require File.join(File.dirname(__FILE__), "../test/" + File.basename(__FILE__, '.rb') + "_test.rb")
end

# :main: ActiveRecord::Acts::DottedPath
module ActiveRecord # :nodoc:
  module Acts # :nodoc:
    # = Acts As Dotted Path
    # 
    # This act provides the capabilities of structuring objects in a hierarchical manner.
    # The hierarchy is stored in a "dotted path," a string of integers (representing
    # ancestor IDs) joined with dots.  For example:
    # 
    #   Pages (id = 1)
    #     Projects (id = 2)
    #       ActsAsDottedPath (id = 3)
    # 
    #   The node 'acts_as_dotted_path' would have dotted path "1.2"
    # 
    # By storing the complete path to a given node in a single column record, bloodlines
    # can be retrieved in a single query.  That is, all ancestors for a given node can be
    # retrieved in a single SQL statement.
    # 
    # The downside, however, is that changing parents requires a more extensive write to 
    # the database.  In particular, a full-table write which uses string replacement to 
    # updated the paths for all children involved in the "adoption."
    # 
    # In addition to the dotted path, a depth attribute is maintained.  The top-most level
    # has a depth of 0.
    # 
    # == Requirements
    # 
    # * Schema:  The schema for the model using this act requires the following columns:
    #   (here we are assuming the default +parent_column+ option +parent_id+)
    #     :parent_id,      :integer
    #     :path,           :string,  :default => ''
    #     :depth,          :integer, :default => 0
    #     :children_count, :integer, :default => 0
    # 
    # * Plugins: This plugin relies on functionality from the DBString plugin, which 
    #   can be obtained via the following command:
    #   
    #   <tt>script/plugin install http://svn.webtest.wvu.edu/repos/rails/plugins/dbstring</tt>
    # 
    # == Examples
    #   
    #   # assume the required schema and an attribute called 'name'
    #   class Page < ActiveRecord::Base
    #     acts_as_dotted_path
    #   end
    # 
    #   pages = Page.create(:name => 'Pages')
    #   pages.children << Page.new(:name => 'Home')
    #   pages.children << Page.new(:name => 'About')
    #   pages.children << Page.new(:name => 'Projects')
    #   pages.children.size # => 3
    # 
    #   projects = pages.children.find_by_name('Projects')
    #   projects.children << Page.new(:name => 'ActsAsDottedPath')
    #   
    #   # bloodline example
    #   p = projects.children.first # => 'ActsAsDottedPath' page
    #   p.bloodline.map(&:name).join(' / ') # => Pages / Projects / ActsAsDottedPath
    # 
    #   # changing parents
    #   pages.children << p
    #   p.bloodline.map(&:name).join(' / ') # => Pages / ActsAsDottedPath
    #   pages.children.size # => 4
    # 
    # For more examples, please refer to <tt>test/acts_as_dotted_path_test.rb</tt>.
    # 
    # == Credits
    # 
    # <tt>acts_as_dotted_path</tt> was created by Chris Scharf (http://tiny.scharfie.com)
    module DottedPath
      def self.included(base) # :nodoc:
        base.extend ClassMethods
        base.extend AssociationExtension
      end
      
      # module for use with :extend option of association methods
      # such as has_many, etc.
      # 
      # Example:
      #   class Site < ActiveRecord::Base
      #     has_many :pages, :extend => ActiveRecord::Acts::DottedPath::AssociationExtension
      #   end
      module AssociationExtension
        def root(node=nil)
          find_root(node) || create_root(node)
        end
        
        def find_root(node=nil)
          find(:first, :conditions => "depth = 0 AND #{node ? node.dotted_path_scope_condition : '1=1'}")
        end
        
        def create_root(node=nil)
          return nil if (node && node.root?) || !ensure_root?
          returning(self.respond_to?(:build) ? self.build : self.new) do |root|
            root.depth = 0
            root[root.dotted_path_parent_column] = 0
            root.send(:before_root, node) if node && root.respond_to?(:before_root)
            root.save
          end  
        end
      end

      module ClassMethods
        # == Configuration options
        # 
        # * +parent_column+ - name of foreign key for parent (defaults to +parent_id+)
        # * +order+ - specifies the order of objects (defaults to +path+)
        # * +scope+ - restricts what objects should be returned.  The value can be one
        #   of the following:
        #   * symbol - column name (_id will be appended if necessary)
        #     
        #     (e.g. <tt>:scope => :site</tt> is essentially <tt>:scope => :site_id</tt>)
        #   * string - custom SQL conditions (interpolation will be performed)
        #   * array  - array of symbols and/or strings for specifying multiple conditions
        #     
        #     (*note*: interpolation of strings in the array is not currently possible)
        # 
        # == Example
        # 
        #   class Site < ActiveRecord::Base
        #     has_many :pages
        #   end
        # 
        #   class Page < ActiveRecord::Base
        #     acts_as_dotted_path :scope => :site
        #     belongs_to :site
        #   end
        # 
        #   my_site  = Site.create(:name => 'My site')
        #   projects = my_site.pages.create(:name => 'Languages')
        #   ruby     = projects.children.create(:name => 'Ruby')
        def acts_as_dotted_path(options = {})
          return if self.included_modules.include?(ActiveRecord::Acts::DottedPath::InstanceMethods)

          configuration = { :parent_column => 'parent_id', :scope => '1 = 1', :order => 'path' }
          configuration.update(options) if options.is_a?(Hash)
          
          scope = configuration[:scope]
          
          class_eval "def self.acts_as_dotted_path_configuration(); #{configuration.inspect}; end"
          
          if scope.is_a?(String)
            class_eval "def dotted_path_scope_condition() \"#{scope}\" end"
          else  
            scope = [scope] unless scope.is_a?(Array)
            define_method 'dotted_path_scope_condition' do
              conditions = [[]]
              scope.flatten.each_with_index do |condition, index|
                case condition
                when Symbol
                  condition = condition.to_s
                  condition += '_id' unless condition =~ /_id$/
                  if self[condition].nil?
                    conditions.first << "#{condition} IS NULL"
                  else
                    conditions.first << "#{condition} = ?"
                    conditions << self[condition]
                  end
                else
                  conditions.first << condition
                end
              end
          
              conditions[0] = conditions.first.join(' AND ')
              ActiveRecord::Base.send(:sanitize_sql, conditions)
            end
          end
          
          define_method 'dotted_path_parent_column' do configuration[:parent_column] end
          define_method 'dotted_path_order' do configuration[:order] end
          foreign_key = configuration[:parent_column]

          class_eval do
            include ActiveRecord::Acts::DottedPath::InstanceMethods
            with_options(:class_name => self.to_s, :foreign_key => foreign_key) do |e|
              e.belongs_to :parent, :counter_cache => :children_count
              e.has_many :children, :before_add => [:set_dotted_path_properties_for_child], 
                :after_add => [:update_dotted_path_for_children], :order => configuration[:order]
            end
            
            before_create :set_dotted_path_properties_from_parent
          end
        end

        def ensure_root?
          !acts_as_dotted_path_configuration[:ensure_root].nil?
        end

        def recount_children!
          counters = Hash.new(0)
          nodes = self.find(:all)
          nodes.each do |e|
            counters[e.parent_id] += 1
          end
          
          nodes.each do |e|
            count = counters[e.id]  
            if e.children_count != count
              e.class.update_counters e.id, :children_count => count
            end  
          end
        end

        # Updates an entire tree based on given mapping data
        # 
        #   * +mapping+ - a string containing comma-separated ID-PID pairs
        #     (where PID is the ID of a parent node)
        # 
        # Example:
        #   Page.remap_tree!("1-0,2-1,3-1")
        #   TODO: finish example
        def remap_tree!(mappings)
          mappings = mappings.split(',').map { |e| e.split('-') }
          counters, path, nodes = [0], [], {}
          
          mappings.each do |id, pid|
            path << pid if path.empty?
            while path.last != pid
              path.pop
              counters.pop
            end
      
            nodes[id.to_s] = { 
              :path => path.join('.'), 
              :depth => path.length,
              :parent_id => pid.to_i, 
              :position => counters[-1] += 1 
            }
      
            unless path.last == id    
              path << id
              counters << 0
            end
          end

          changed_nodes = []
          original_nodes = self.find(:all)
          original_nodes.each do |e|
            new_data = nodes[e.id.to_s]
            next if new_data.nil?
            old_data = { :parent_id => e.parent_id, :depth => e.depth, :path => e.path, :position => e.position }
            unless old_data == new_data
              e.update_attributes(new_data) 
              changed_nodes << e
            end  
          end  
          
          # now we need to fix the children counters
          self.recount_children!
          
          changed_nodes        
        end
      end

      module InstanceMethods
        attr_accessor :dotted_path_previous_parent
        
        # sets dotted path related properties for given
        # child based on properties of current object (parent)
        def set_dotted_path_properties_for_child(child)
          self.dotted_path_previous_parent = child.parent
          child.set_dotted_path_properties_from_parent(self)
        end
        
        # sets dotted path related properties for object
        # based on properties of parent
        # 
        # this method is used as a +before_create+ callback
        # to ensure that an object is properly related to 
        # a parent object IF the parent column value is set,
        # which this enables simple creation of relationships
        # by setting the parent column when creating an object
        def set_dotted_path_properties_from_parent(parent=nil)
          parent = self.parent if parent.nil?
          parent = self.class.root(self) if parent.nil? && !self.root? && self.class.ensure_root?
          
          unless parent.nil?
            self[dotted_path_parent_column] = parent.id
            self.path = parent.path_with_id
            self.depth = parent.depth + 1
          end  
          
          return true
        end
        
        # updates dotted path for all children to ensure
        # hierarchy and counter caches are correct
        # (called after a child is added to an object)
        def update_dotted_path_for_children(child=nil)
          # old_parent = self.class.find_by_id(dotted_path_previous_parent_id)
          old_parent = dotted_path_previous_parent
          if !old_parent.nil?
            if old_parent != self
              # the path we need to find
              base_path    = old_parent.path_with_id + '.' + id.to_s 
      
              # the new base path to use
              new_base_path = path_with_id + '.' + id.to_s
      
              # the difference in depths for the move (so we can update the child depths)
              depth_delta = self.depth + 1 - depth
      
              # build the path SQL
              column, start, length = :path, base_path.length + 1, 8000
              substring_sql = if connection.respond_to?(:substring)
                connection.substring(column, start, length)
              else
                raise 'This action requires the DBString plugin.'
              end
      
              # update the node's children
              sql = <<-SQL
                UPDATE #{self.class.table_name}
                SET path = ('#{new_base_path}' + #{substring_sql}), depth = depth + #{depth_delta}
                WHERE #{dotted_path_scope_condition} AND path LIKE '#{base_path}% AND id != #{self.id}'
              SQL
              ActiveRecord::Base.connection.execute(sql)
              
              # decrement the old parent's counter cache
              self.class.decrement_counter(:children_count, old_parent.id)
              old_parent.children_count -=1
            end
          end

          # increment the new parent's counter cache
          self.class.increment_counter(:children_count, self.id)
          self.children_count += 1
        end

        # returns the dotted path joined with
        # the ID of the current object
        def path_with_id
          [self.path, self.id.to_s].reject(&:blank?).join('.')
        end
        
        # returns true if the specified object
        # (or ID) is a descendant
        def descendant?(child)
          child = self.class === child ? child : self.find_by_id(child)
          child.path.include?(self.path_with_id) && !child.path.blank? && child.path != self.path
        end
        
        # returns collection of all descendants
        # (all items with path LIKE path_with_id)
        def descendants(options={})
          options[:order] ||= self.dotted_path_order
          self.class.send(:with_scope, :find => { 
            :conditions => ["#{dotted_path_scope_condition} AND path LIKE ?", path_with_id + '%'] }) do
            self.class.find(:all, options)
          end          
        end
        
        # returns true if the specified object
        # (or ID) is an ancestor 
        def ancestor?(e)
          e = self.class === e ? e.id : e
          path.split('.').include?(e.to_s)
        end
      
        # returns collection of all ancestors
        # (determined by path)
        def ancestors(options={})
          options[:order] ||= 'depth'
          
          ids = self.path.split('.').reject(&:empty?)
      
          return [] if ids.empty?
          self.class.send(:with_scope, :find => { 
            :conditions => "#{dotted_path_scope_condition} AND id IN (" + ids.join(',') + ")" }) do
            self.class.find(:all, options)
          end
        end
      
        # returns collection of all objects
        # in the bloodline (path) (including self)
        def bloodline(options = {})
          ancestors.push(self)
        end
        
        # returns collection of all direct siblings
        # (items having the same parent and depth as self)
        # top-level nodes are returned when parent is nil or 0
        # 
        # Options: accepts ActiveRecord find() options as well as:
        #   :self -- if true, include self in collection (default false)
        def siblings(options = {})
          pid = self[dotted_path_parent_column]
          vdepth = self.depth
          include_self = options.delete(:self) || false
          self_condition = " AND id != #{id}" if !include_self && !new_record?
          
          # handle the special case of parent column
          # being nil or 0 - return all top level nodes
          # in this case
          if pid.nil? || pid == 0
            self.class.send(:with_scope, :find => {
              :conditions => ["#{dotted_path_scope_condition} AND depth = 0 #{self_condition}"] }) do
              self.class.find(:all, options)
            end  
          else
            self.class.send(:with_scope, :find => {
              :conditions => ["#{dotted_path_scope_condition} AND depth = ? AND #{dotted_path_parent_column} = ? #{self_condition}", 
              self.depth, pid] }) do
              self.class.find(:all, options)
            end
          end
        end
        
        # returns true if the page is a root page
        def root?
          self.depth == 0 && self.send(dotted_path_parent_column) == 0
        end
        
        # # changes the parent of the current object
        # # to the specified parent
        # # (note that this requires a full table write
        # # in order to update the hierarchy)
        # def change_parent(parent)
        #   # the path we need to find
        #   base_path = path_with_id
        #       
        #   # the new base path to use
        #   new_base_path = parent.path_with_id + id.to_s + '/'
        #       
        #   # the difference in depths for the move (so we can update the child depths)
        #   depth_delta = parent.depth + 1 - depth
        #       
        #   # update the node
        #   update_attributes self.dotted_path_parent_column => parent.id,
        #     :path  => parent.path_with_id,
        #     :depth => parent.depth + 1
        #       
        #   # build the path SQL
        #   column, start, length = :path, base_path.length + 1, 8000
        #   substring_sql = if connection.respond_to?(:substring)
        #     connection.substring(column, start, length)
        #   else
        #     raise 'This action requires the DBString plugin.'
        #   end
        #       
        #   # update the node's children
        #   sql = <<-SQL
        #     UPDATE #{self.class.table_name}
        #     SET path = ('#{new_base_path}' + #{substring_sql}), depth = depth + #{depth_delta}
        #     WHERE #{dotted_path_scope_condition} AND path LIKE '#{base_path}%'
        #   SQL
        #   
        #   # if dotted_path_use_counter_cache
        #   #   old_parent.decrement(children_count)
        #   #   new_parent.increment(children_count)
        #   # end
        #   
        #   ActiveRecord::Base.connection.execute(sql)
        # end
        
        # def update_children(updates, conditions = nil)
        #   conditions = ["#{dotted_path_scope_condition} AND path LIKE '#{path_with_id}%'", conditions].compact.join(' AND ')
        #   self.class.update_all(updates, conditions)
        # end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::DottedPath