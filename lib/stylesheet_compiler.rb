class StylesheetCompiler
  include CssDryer
  
  # Processes all given files, defaulting to
  # +StylesheetCompiler#default_files+
  def process_files(files=default_files)
    files.each do |source, destination|
      process_file source, destination
    end
  end
  
  # Returns an array of source-destination pairs
  # for all files to process
  # For example, 
  #   [
  #     ['root/app/views/stylesheets/a.ncss', 
  #      'root/public/stylesheets/a.css'
  #     ], 
  #     ...
  #   ]
  def default_files
    source_files = Dir[RAILS_ROOT / 'app/views/stylesheets/*.ncss']
    source_files.map do |source|
      [source, destination_path(source)]
    end
  end
  
  # Returns the destination path to given source file
  def destination_path(source)
    File.join RAILS_ROOT, 'public/stylesheets', 
      File.basename(source, '.ncss') + '.css'
  end
  
  # Compiles the source file into destination file
  # using css_dryer
  def process_file(source, destination=nil)
    destination ||= destination_path(source) 
    output = process(File.read(source))
    File.open(destination, 'w') { |f| f.write(output) }
  end
end