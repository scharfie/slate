require File.dirname(__FILE__) + '/abstract_unit'

class Slate::DBString::TestAdapter
  include Slate::DBString
  attr_accessor :adapter_class
  
  def initialize(adapter) 
    @adapter_class = adapter + 'Adapter' 
  end
end

class DbstringTest < Test::Unit::TestCase
  def setup
    %w(Mysql SQLite SQLServer PostgreSQL).each do |adapter|
      klass = Slate::DBString::TestAdapter
      instance_variable_set('@' + adapter.downcase, klass.new(adapter))
    end
  end
  
  def test_concat
    assert_equal("CONCAT(first_name,last_name)", @mysql.concat('first_name', 'last_name'))    
    assert_equal("first_name || last_name", @postgresql.concat('first_name', 'last_name'))    
    assert_equal("first_name || last_name", @sqlite.concat('first_name', 'last_name'))    
    assert_equal("first_name + last_name", @sqlserver.concat('first_name', 'last_name'))    
  end
  
  def test_substring
    assert_equal("SUBSTRING(name FROM 1 FOR 3)", @postgresql.substring('name', 1, 3))
    assert_equal("SUBSTRING(name, 1, 3)", @mysql.substring('name', 1, 3))
    assert_equal("SUBSTR(name, 1, 3)",    @sqlite.substring('name', 1, 3))
    assert_equal("SUBSTRING(name, 1, 3)", @sqlserver.substring('name', 1, 3))
  end
  
  def test_year
    assert_equal("YEAR(created_on)", @mysql.year('created_on'))
    assert_equal("DATE_PART('YEAR', created_on)", @postgresql.year('created_on'))
    assert_equal("CAST(strftime('%Y', created_on) AS INTEGER)", @sqlite.year('created_on'))
    assert_equal("YEAR(created_on)", @sqlserver.year('created_on'))
  end
  
  def test_month  
    assert_equal("MONTH(created_on)", @mysql.month('created_on'))
    assert_equal("DATE_PART('MONTH', created_on)", @postgresql.month('created_on'))
    assert_equal("MONTH(created_on)", @sqlserver.month('created_on'))
    assert_equal("CAST(strftime('%m', created_on) AS INTEGER)", @sqlite.month('created_on'))    
  end
  
  def test_day  
    assert_equal("DAY(created_on)", @mysql.day('created_on'))
    assert_equal("DATE_PART('DAY', created_on)", @postgresql.day('created_on'))
    assert_equal("DAY(created_on)", @sqlserver.day('created_on'))
    assert_equal("CAST(strftime('%d', created_on) AS INTEGER)", @sqlite.day('created_on'))    
  end  
end

class DbStringWithAdapterTest < Test::Unit::TestCase
  attr_accessor :connection
  
  def setup
    self.connection = ActiveRecord::Base.connection
    create_fixtures :users
  end
  
  def assert_query(expected, query)
    query = 'SELECT %s AS query_result FROM users WHERE id = 1' % [query]
    actual = connection.select_one(query)['query_result']
    assert_equal(expected, actual)
  end
  
  def test_concat
    assert_query('ChristopherScharf', connection.concat('first_name', 'last_name'))
  end
  
  def test_substring
    assert_query('Chris', connection.substring('first_name', 1, 5))
  end
  
  def test_year
    assert_query('2007', connection.year(:created_on))
  end
  
  def test_month
    assert_query('9', connection.month(:created_on))
  end
  
  def test_day
    assert_query('7', connection.day(:created_on))
  end
  
  def test_complex
    query = connection.substring('first_name', 1, 5)
    query = connection.concat(query, 'last_name')
    assert_query('ChrisScharf', query)
  end
end
