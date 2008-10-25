# This is for running specs against target versions of rails
#
# To use do
#   - cp garlic_example.rb garlic.rb
#   - rake get_garlic
#   - [optional] edit this file to point the repos at your local clones of
#     rails, rspec, and rspec-rails
#   - rake garlic:all
#
# All of the work and dependencies will be created in the galric dir, and the
# garlic dir can safely be deleted at any point

garlic do
  # default paths are 'garlic/work', and 'garlic/repos'
  # work_path 'garlic/work'
  # repo_path 'garlic/repos'

  # repo, give a url, specify :local to use a local repo (faster
  # and will still update from the origin url)
  repo 'rails', :url => 'git://github.com/rails/rails' #,  :local => "~/dev/vendor/rails"
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec' #, :local => "~/dev/vendor/spec"
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails' #, :local => "~/dev/vendor/spec"
  
  # these are for testing rails-2.0-2.1 branch
  repo 'ianwhite-rspec', :url => 'git://github.com/ianwhite/rspec' #, :local => "~/dev/ianwhite/spec"
  repo 'ianwhite-rspec-rails', :url => 'git://github.com/ianwhite/rspec-rails' #, :local => "~/dev/ianwhite/spec"
  
  repo 'inherit_views', :path => '.'

  # for target, default repo is 'rails', default branch is 'master'
  target 'edge', :branch => 'origin/master' do
    prepare do
      plugin 'inherit_views', :branch => 'origin/master', :clone => true
      plugin 'rspec'
      plugin 'rspec-rails' do
        sh "script/generate rspec -f"
      end
    end
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec:rcov:verify"
      end
    end
  end
  
  target '2.0-stable', :branch => 'origin/2-0-stable' do
    prepare do
      plugin 'inherit_views', :branch => 'origin/rails-2.0-2.1', :clone => true
      plugin 'ianwhite-rspec', :as => 'rspec'
      plugin 'ianwhite-rspec-rails', :as => 'rspec-rails' do
        sh "script/generate rspec -f"
      end
    end
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec"
      end
    end
  end
  
  target '2.1-stable', :branch => 'origin/2-1-stable' do
    prepare do
      plugin 'inherit_views', :branch => 'origin/rails-2.0-2.1', :clone => true
      plugin 'ianwhite-rspec', :as => 'rspec'
      plugin 'ianwhite-rspec-rails', :as => 'rspec-rails' do
        sh "script/generate rspec -f"
      end
    end
    run do
      cd "vendor/plugins/inherit_views" do
        sh "rake spec"
      end
    end
  end
end
