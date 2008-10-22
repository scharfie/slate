require 'test/unit'
require 'active_record'
require 'active_record/fixtures'

require File.dirname(__FILE__) + '/../lib/active_record/associated_save.rb'
require File.dirname(__FILE__) + '/../init.rb'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', 
  :database => File.dirname(__FILE__) + '/associated_save.sqlite3'
)

ActiveRecord::Schema.verbose = false
load(File.dirname(__FILE__) + '/schema.rb')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
  
  def logger
    ActiveRecord::Base.logger
  end

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
