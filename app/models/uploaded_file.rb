class UploadedFile
  attr_accessor :file, :filename, :original_filename
  
  def initialize(filename, original_filename=nil)
    self.file, self.filename = if filename.is_a?(String)
      [nil, filename]
    else
      filename.rewind
      [filename, filename.respond_to?(:path) ?  filename.path : original_filename]
    end
      
    @original_filename = original_filename || File.basename(self.filename)
  end
  
  # rewinds the file if there is a file object
  def rewind
    file ? file.rewind : nil
  end
  
  # returns the content type of the file
  # (using mimetype_fu)
  def content_type
    File.mime_type?(original_filename)
  end
  
  # returns the contents of the file
  def read
    file ? file.read : File.read(self.filename)
  end
  
  # returns the length of the file
  def length
    file ? file.length : File.size(self.filename)
  end
  
  # alias length as size for attachment_fu
  alias_method :size, :length
end