namespace 'stylesheets' do
  desc 'Compiles css_dryer stylesheets'
  task :compile => :environment do
    StylesheetCompiler.new.process_files
  end
end

desc 'Compiles css_dryer stylesheets'
task :stylesheets => 'stylesheets:compile'