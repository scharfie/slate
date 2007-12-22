require 'rake/testtask'

TEST_FILE = File.join(File.dirname(__FILE__), '../test/dbstring_test.rb')
ADAPTERS  = %w(sqlite mysql postgresql)

def test_task_for_adapter(adapter)
  desc "Run tests for " + adapter + " adapter"
  task(adapter) do
    system "ruby #{TEST_FILE} DB=#{adapter}"
  end
end

namespace :dbstring do
  desc 'Run tests for all databases'
  task :test do
    exceptions = ADAPTERS.collect do |task|
      begin
        Rake::Task['dbstring:test:' + task].invoke
        nil
      rescue => e
        e
      end
    end.compact
  
    exceptions.each { |e| puts e }
    raise "Test failures" unless exceptions.empty?
  end

  namespace :test do
    ADAPTERS.each do |adapter|
      test_task_for_adapter(adapter)
    end
  end 
end