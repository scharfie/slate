namespace :plugins do
  desc "Lists installed plugins"
  task :list => :environment do
    Slate.plugins.each do |plugin| 
      puts plugin.key
      plugin.pending_migrations_error if plugin.pending_migrations?
    end
  end
  
  desc "Migrate plugins. Target specific plugin with PLUGIN=x.  Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    Slate::Migrator.migrate(ENV['PLUGIN'], ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  namespace :migrate do
    desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
    task :redo => :environment do
      if ENV["VERSION"]
        Rake::Task["plugins:migrate:down"].invoke
        Rake::Task["plugins:migrate:up"].invoke
      else
        Rake::Task["plugins:rollback"].invoke
        Rake::Task["plugins:migrate"].invoke
      end
    end

    desc 'Runs the "up" for a given migration VERSION.'
    task :up => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      Slate::Migrator.run(:up, ENV['PLUGIN'], version)
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      Slate::Migrator.run(:down, ENV['PLUGIN'], version)
    end
  end

  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    Slate::Migrator.rollback(ENV['PLUGIN'], step)
  end
end

#     desc "Run core and Slate plugin migrations"
#     task :all => ['db:migrate', 'db:migrate:plugins'] do
#       # Nothing else to do :-)
#     end