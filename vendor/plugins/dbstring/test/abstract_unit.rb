require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require File.dirname(__FILE__) + '/../lib/dbstring'

if ENV['DB'].blank?
  DATABASE = (ARGV.shift || 'sqlite').gsub(/^DB=/, '')
  ENV['DB'] = DATABASE
end

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')

database_config = config[ENV['DB']]
database_config['database'] = File.join(File.dirname(__FILE__), database_config['database']) if ENV['DB'] == 'sqlite'

ActiveRecord::Base.establish_connection(database_config)
ActiveRecord::Schema.verbose = false
load(File.dirname(__FILE__) + '/schema.rb')

puts '-' * 80
puts "Connection established: \n  " + ActiveRecord::Base.connection.class.to_s
puts '-' * 80

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