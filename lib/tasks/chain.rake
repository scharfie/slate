require 'open-uri'
namespace :chain do
  desc "Updates the chain.js library from github"
  task :update => :environment do
    contents = open('http://github.com/raid-ox/chain.js/tree/master%2Fbuild%2Fchain.js?raw=true').read
    File.open(Rails.public_path / 'javascripts/chain.js', 'w') do |f|
      f.write contents
    end  
  end
end