ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.join(File.dirname(__FILE__), "../../../../config/environment"))
require 'spec/rails'
require 'ostruct'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'
end