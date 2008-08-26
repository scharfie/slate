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
  repo 'rails', :url => 'git://github.com/rails/rails'#,  :local => "~/dev/vendor/rails"
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'#,  :local => "~/dev/vendor/rspec"
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'#, :local => "~/dev/vendor/rspec-rails"
  repo 'response_for', :path => '.'

  # for target, default repo is 'rails', default branch is 'master'
  target 'edge' do
    prepare do
      plugin 'response_for', :clone => true # so we can work on it and push fixes upstream
    end
  end
  
  target '2.1-RC1' do
    prepare do
      plugin 'response_for', :clone => true
    end
  end
  
  target '2.0-stable', :branch => 'origin/2-0-stable' do
    prepare do
      plugin 'response_for', :branch => 'origin/2.0-stable', :clone => true
    end
  end
    
  target '2.0.2', :tag => 'v2.0.2' do
    prepare do
      plugin 'response_for', :branch => 'origin/2.0-stable', :clone => true
    end
  end
  
  target '2.0.3', :tag => 'v2.0.3' do
    prepare do
      plugin 'response_for', :branch => 'origin/2.0-stable', :clone => true
    end
  end

  all_targets do
    prepare do
      plugin 'rspec'
      plugin('rspec-rails') { sh "script/generate rspec -f" }
    end
  
    run do
      cd "vendor/plugins/response_for" do
        sh "rake spec:rcov:verify"
      end
    end
  end
end
