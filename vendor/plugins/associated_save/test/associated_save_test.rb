require File.dirname(__FILE__) + '/abstract_unit'

class Collection < ActiveRecord::Base
  has_many :items
  associated_save :items
end

class Item < ActiveRecord::Base
  belongs_to :collection
end

class AssociatedSaveTest < Test::Unit::TestCase
  def setup
    @library = Collection.create(:name => 'Book Library')
  end
  
  def test_reflection
    reflection = Collection.reflect_on_associated_save(:items)
    assert_equal '_items', reflection[:from]
    assert_equal 'save_associated_items', reflection[:callback]
    
    assert Collection.instance_methods.include?('associated_items')
  end
  
  def test_assignment
    @library.attributes = {
      '_items' => [
        { 'name' => 'To Kill A Mockingbird' },
        { 'name' => 'The Great Gatsby' },
      ]
    }
    
    books = @library.associated_save_objects(:items)
    assert_equal(2, books.length)
    
    assert_equal('To Kill A Mockingbird', books.first.name)
    assert_equal('The Great Gatsby', books.last.name)
    
    assert_equal(0, books.first.position)
    assert_equal(1, books.last.position)
  end
end
