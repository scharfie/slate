garlic do
  repo 'inherit_views', :path => '.'

  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'

  # first is rails target, last is inherit views branch
  [ 
    {:rails => 'master',      :inherit_views => 'master'},
    {:rails => '2-2-stable',  :inherit_views => 'rails-2.2'},
    {:rails => '2-1-stable',  :inherit_views => 'rails-2.0-2.1'}
    #{:rails => '2-0-stable',  :inherit_views => 'rails-2.0-2.1'} rspec + raisl 2.0 is not playing nice at the moment
  ].each do |target|

    target target[:rails], :branch => "origin/#{target[:rails]}" do
      prepare do
        plugin 'inherit_views', :branch => "origin/#{target[:inherit_views]}", :clone => true
        plugin 'rspec', :branch => 'origin/1.1-maintenance'
        plugin 'rspec-rails', :branch => 'origin/1.1-maintenance' do
          sh "script/generate rspec -f"
        end
      end
      run do
        cd "vendor/plugins/inherit_views" do
          sh "rake rcov:verify"
        end
      end
    end
    
  end
end