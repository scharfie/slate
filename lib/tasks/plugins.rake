require 'rake/testtask'

namespace :db do
  namespace :migrate do
    desc "Run all Slate plugin migrations"
    task :plugins => :environment do
      Slate::Plugin::Migrator.migrate_plugins
    end
  end
end  