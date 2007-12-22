desc "Touches files storing revisions so that svn will update $LastChangedRevision"
task :update_revision do
  # See http://svnbook.red-bean.com/en/1.0/ch07s02.html - the section on svn:keywords
  files = %w(lib/slate/version.rb)

  touch_needed = false
  
  lines = `svn status --ignore-externals`
  lines.split("\n").each do |line| 
    if line =~ /^(M|A|\sM)\s*(.*)/
      touch_needed = !files.index($1)
      break if touch_needed
    end
  end
  
  if touch_needed
    new_token = rand
    files.each do |path|
      abs_path = File.join(File.dirname(__FILE__), '../../', path)
      content = File.open(abs_path).read
      touched_content = content.gsub(/# RANDOM_TOKEN: (.*)\n/n, "# RANDOM_TOKEN: #{new_token}\n")
      File.open(abs_path, 'w') do |io|
        io.write touched_content
      end
    end
  end
end