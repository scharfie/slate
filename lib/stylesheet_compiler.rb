class StylesheetCacher
  include CssDryer
  
  def self.run
    sc = self.new
    Dir[RAILS_ROOT / 'app/views/stylesheets/*.ncss'].each do |file|
      sc.process_file(file)
    end
    
    print "\n"
  end
  
  def process_file(src)
    dst = RAILS_ROOT / 'public/stylesheets' / File.basename(src, '.ncss') + '.css'
    print "\nCaching #{File.basename(dst)}..."
    output = process(File.read(src))
    File.open(dst, 'w') { |f| f.write(output) }
    # `svn add #{dst}`
    print 'done.'
  end
end

StylesheetCacher.run
