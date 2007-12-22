# we have to provide the full path because the
# rspec plugin hasn't loaded yet
require 'vendor/plugins/rspec/lib/spec/rake/spectask'
require 'vendor/plugins/rspec/lib/spec/rake/verify_rcov'

desc "Run all specs with RCov, verify coverage, and display report"
task :report do
  ENV['RCOV_OPTS'] = "--exclude spec --rails --text-report"
  ENV['RCOV_OPTS'] << ' --exclude lib/slate/ldap.rb --exclude app/models/ldap_spec.rb' if ENV['LDAP'] == 'false'
    
  Rake::Task['update_revision'].invoke
  Rake::Task['spec:rcovv'].invoke
  puts ""
  Rake::Task['stats'].invoke
end

namespace :spec do
  desc 'Verify that spec coverage is 100%'
  RCov::VerifyTask.new(:rcovv => :rcov) do |t|
    puts ""
    t.threshold = 100.0
    t.index_html = './coverage/index.html'
  end
end